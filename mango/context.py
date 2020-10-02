from typing import List, Set, Dict

import mango.mango_ext.context as ext
from mango.mango_ext.logger import init_logger
from mango._utils import exit_code_to_exception
from mango.buffer import Buffer, BufferBuilder, FIFOBuffer
from mango.task_graph import TaskGraph
from mango.kernel import Kernel, KernelBuilder
from mango.kernel_arguments import KernelArguments
from mango.event import Event, EventBuilder
from mango.kernel_function import KernelFunction

class AllocatedContextManager:
    def __init__(self, ctx, tg: TaskGraph):
        self.ctx = ctx
        self.tg = tg

    def __enter__(self):
        pass

    def __exit__ (self, type, value, tb):
        self.ctx.resource_deallocation(self.tg)

class BBQContext:
    _inner: ext.BBQContext
    kernels_in: Dict[int, Set[int]] = {} # dictionary mapping kernels_in given a buffer id
    kernels_out: Dict[int, Set[int]] = {} # dictionary mapping kernels_out given a buffer id

    def __init__(self, name: str, recipe: str):
        init_logger()
        self._inner = ext.BBQContext.create(name, recipe)

    def resource_allocation(self, tg: TaskGraph) -> AllocatedContextManager:
        res = self._inner.resource_allocation(tg._inner)
        exit_code_to_exception(res)
        return AllocatedContextManager(self, tg)

    def resource_deallocation(self, tg: TaskGraph) -> None:
        res = self._inner.resource_deallocation(tg._inner)
        exit_code_to_exception(res)

    def start_kernel(self, kernel: Kernel, args: KernelArguments, event: Event = None) -> Event:
        inner_ev = event._inner if event is not None else None
        return Event(_event = self._inner.start_kernel(kernel._inner, args._inner, inner_ev))

    def register_kernel(self, kernel: KernelBuilder) -> Kernel:
        for b in kernel.buffers_out:
            kernels_in = self.kernels_in.get(b.id, set())
            kernels_in.add(kernel.id)
            self.kernels_in[b.id] = kernels_in

        for b in kernel.buffers_in:
            kernels_out = self.kernels_out.get(b.id, set())
            kernels_out.add(kernel.id)
            self.kernels_out[b.id] = kernels_out

        return Kernel(_k= self._inner.register_kernel(kernel.id, kernel.kf._inner, [b.id for b in kernel.buffers_in], [b.id for b in kernel.buffers_out]))

    def register_buffer(self, buffer: BufferBuilder) -> Buffer:
        kernels_in = list(self.kernels_in.get(buffer.id, set()))
        kernels_out = list(self.kernels_out.get(buffer.id, set()))
        
        b = None
        if (buffer.is_fifo):
            b = FIFOBuffer(buffer.id, buffer.size, kernels_in, kernels_out)
        else:
            b = Buffer(buffer.id, buffer.size, kernels_in, kernels_out)

        return Buffer(_buffer= self._inner.register_buffer(b._inner, buffer.id))

    def deregister_buffer(self, buffer_id: int) -> None:
        self._inner.deregister_buffer(buffer_id)

    def register_event(self, event: EventBuilder) -> Event:
        ev = Event([k.id for k in event.kernels_in], [k.id for k in event.kernels_out])
        return Event(_event= self._inner.register_event(ev._inner))

    def get_kernel(self, id: int) -> Kernel:
        return Kernel(_k= self._inner.get_kernel(id))

    def get_buffer(self, id: int) -> Buffer:
        return Buffer(_buffer= self._inner.get_buffer(id))

    def get_event(self, id: int) -> Event:
        return Event(_event= self._inner.get_event(id))
