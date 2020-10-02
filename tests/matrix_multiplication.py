import numpy as np
from mango import (
    BBQContext, KernelFunction, UnitType, KernelBuilder,
    FileType, BufferBuilder, TaskGraph, BufferArg, 
    ScalarArg, ScalarType, EventArg, KernelArguments,
)
import sys

size = int(sys.argv[1]) if len(sys.argv) > 1 else 5
int_size = 4

matrix = [list(range(0, size)) for _ in range(0, size)]

A = np.array(matrix, dtype=np.int32)
B = np.array(matrix, dtype=np.int32)
expected_result = A.dot(B)

buffer_size = size ** 2 * int_size
C = bytearray(buffer_size)

ctx = BBQContext("matrix_multiplication", "test_manga")

kernel_file = "/opt/mango/usr/local/share/matrix_multiplication/matrix_multiplication_dev"

kf = KernelFunction()
kf.load(kernel_file, UnitType.GN, FileType.BINARY)

bb1 = BufferBuilder(buffer_size)
bb2 = BufferBuilder(buffer_size)
bb3 = BufferBuilder(buffer_size)

kb = KernelBuilder(kf, buffers_in=[bb1, bb2], buffers_out=[bb3])

k = ctx.register_kernel(kb)

b1 = ctx.register_buffer(bb1)
b2 = ctx.register_buffer(bb2)
b3 = ctx.register_buffer(bb3)

tg = TaskGraph(
    kernels=[k], 
    buffers=[b1, b2, b3]
)

with ctx.resource_allocation(tg):
    arg1 = BufferArg(b1)
    arg2 = BufferArg(b2)
    arg3 = BufferArg(b3)
    arg4 = ScalarArg(size, ScalarType.INT)
    arg5 = ScalarArg(size, ScalarType.INT)
    ev = b3.get_event() # get_event can only be called after resource allocation
    arg6 = EventArg(ev)

    args = KernelArguments(k, arg1, arg2, arg3, arg4, arg5, arg6)

    b1.write(A.tobytes())
    b2.write(B.tobytes())

    end_ev = ctx.start_kernel(k, args)

    ev.wait()
    b3.read(C)

    end_ev.wait()

actual = np.frombuffer(C, dtype=np.int32).reshape(size, size)

assert np.array_equal(expected_result, actual)

print("\n\n-----------------------------------------------\n\n")
print("Matrix multiplication performed correctly")
print("\n\n-----------------------------------------------\n\n")
