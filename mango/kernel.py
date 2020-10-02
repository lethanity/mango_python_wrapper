from typing import List

import mango.mango_ext.kernel as ext
from mango.kernel_function import KernelFunction
from mango.buffer import BufferBuilder

class KernelBuilder:
    id_counter = 1

    id: int 
    kf: KernelFunction
    buffers_in: List[BufferBuilder]
    buffers_out: List[BufferBuilder]

    def __init__(self, kf: KernelFunction, buffers_in: List[BufferBuilder] = [], buffers_out: List[BufferBuilder] = []):
        self.id = KernelBuilder.id_counter
        self.kf = kf
        self.buffers_in = buffers_in
        self.buffers_out = buffers_out
        KernelBuilder.id_counter += 1

class Kernel:
    _inner: ext.Kernel

    def __init__(self, id: int = 0, kf: KernelFunction = None, buffers_in: List[int] = [], buffers_out: List[int] = [], _k: ext.Kernel = None):
        if _k is not None:
            self._inner = _k
        else:
            self._inner = ext.Kernel.create(id, kf, buffers_in, buffers_out)

    @property
    def id(self) -> int:
        return self._inner.get_id()
    