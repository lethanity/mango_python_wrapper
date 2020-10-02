import numpy as np
from mango.mango_ext.context import BBQContext
from mango.mango_ext.kernel_function import KernelFunction
from mango.mango_ext.mango_types import UnitType, FileType
from mango.mango_ext.buffer import Buffer
from mango.mango_ext.task_graph import TaskGraph
from mango.mango_ext.kernel_arguments import BufferArg, ScalarArg, EventArg, KernelArguments, ScalarType
from mango.mango_ext.logger import init_logger

# Matrix multiplication sample replicated using only cython extensions

init_logger()

KID = 1
B1 = 1
B2 = 2
B3 = 3

rows = 5
cols = 5
int_size = 4

A = np.array([[0, 1, 2, 3, 4], [0, 1, 2, 3, 4], [0, 1, 2, 3, 4], [0, 1, 2, 3, 4], [0, 1, 2, 3, 4]], dtype=np.int32)
B = np.array([[0, 1, 2, 3, 4], [0, 1, 2, 3, 4], [0, 1, 2, 3, 4], [0, 1, 2, 3, 4], [0, 1, 2, 3, 4]], dtype=np.int32)
expected_result = A.dot(B)

C = bytearray(rows * cols * int_size)

ctx = BBQContext.create("matrix_multiplication", "test_manga")

kernel_file = "/opt/mango/usr/local/share/matrix_multiplication/matrix_multiplication_dev"

kf = KernelFunction.create()
kf.load(kernel_file, UnitType.GN, FileType.BINARY)

k = ctx.register_kernel(KID, kf, [B1, B2], [B3])

b1 = ctx.register_buffer(Buffer.create(B1, rows * cols * int_size, [], [KID]), B1)
b2 = ctx.register_buffer(Buffer.create(B2, rows * cols * int_size, [], [KID]), B2)
b3 = ctx.register_buffer(Buffer.create(B3, rows * cols * int_size, [KID], []), B3)

tg = TaskGraph.create_full([ctx.get_kernel(KID)], [ctx.get_buffer(B1), ctx.get_buffer(B2), ctx.get_buffer(B3)], [])

ctx.resource_allocation(tg)

arg1 = BufferArg.create(b1)
arg2 = BufferArg.create(b2)
arg3 = BufferArg.create(b3)
arg4 = ScalarArg.create(rows, ScalarType.INT)
arg5 = ScalarArg.create(cols, ScalarType.INT)
ev = ctx.get_buffer(B3).get_event()
arg6 = EventArg.create(ev)

args = KernelArguments.create([arg1, arg2, arg3, arg4, arg5, arg6], k)

b1.write(bytearray(A.tobytes()))
b2.write(bytearray(B.tobytes()))

end_ev = ctx.start_kernel(k, args, None)

ev.wait()
b3.read(C)

end_ev.wait()

ctx.resource_deallocation(tg)

actual = np.frombuffer(C, dtype=np.int32).reshape(rows, cols)

assert np.array_equal(expected_result, actual)

print("\n\n-----------------------------------------------\n\n")
print("Matrix multiplication performed correctly")
print("\n\n-----------------------------------------------\n\n")
