from mango import (
    BBQContext, KernelFunction, UnitType, FileType,
    KernelBuilder, BufferBuilder, EventBuilder,
    TaskGraph, ScalarArg, BufferArg, EventArg,
    ScalarType, KernelArguments,
)

N = 3
UINT64_SIZE = 8

ctx = BBQContext("sync", "generic_manga")

kernel_file = "/opt/mango/usr/local/share/sync/sync_dev"

kf = KernelFunction()
kf.load(kernel_file, UnitType.GN, FileType.BINARY)

bb = BufferBuilder(UINT64_SIZE)
kb = KernelBuilder(kf, buffers_out=[bb])
eb = EventBuilder(kernels_in=[kb], kernels_out=[kb])


k1 = ctx.register_kernel(kb)
b1 = ctx.register_buffer(bb)
e1 = ctx.register_event(eb)

tg = TaskGraph(
    kernels=[k1],
    buffers=[b1],
    events=[e1],
)

with ctx.resource_allocation(tg):
    arg1 = ScalarArg(N, ScalarType.UINT)
    arg2 = EventArg(e1)
    arg3 = BufferArg(b1)
    args = KernelArguments(k1, arg1, arg2, arg3)

    ev = ctx.start_kernel(k1, args)

    for i in range(N):
        print("HOST: Waiting 1...", 1)
        e1.wait_state(1)
        print("HOST: Signaling 2...", 2)
        e1.write(2)

    ev.wait()