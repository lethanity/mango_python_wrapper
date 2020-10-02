from typing import List, Union

import mango.mango_ext.buffer as ext
from mango.event import Event

class BufferBuilder:
    id_counter = 1

    id: int
    size: int

    def __init__(self, size: int, is_fifo=False):
        assert size > 0, "Buffer size must be greater than 0"
        self.id = BufferBuilder.id_counter
        self.size = size
        self.is_fifo = is_fifo
        BufferBuilder.id_counter += 1

class Buffer:
    _inner: ext.Buffer

    def __init__(self, id: int = 0, size: int = 0, kernels_in: List[int] = [], kernels_out: List[int] = [], _buffer: ext.Buffer = None):
        if _buffer is not None:
            self._inner = _buffer
        else:
            assert size > 0, "Buffer size must be greater than 0"
            self._inner = ext.Buffer.create(id, size, kernels_in, kernels_out)

    def write(self, buffer: Union[bytearray, bytes], global_size: int = 0):
        buf_arg = buffer if type(buffer) is bytearray else bytearray(buffer)
        return self._inner.write(buf_arg, global_size)

    def read(self, buffer: bytearray, global_size: int = 0):
        return self._inner.read(buffer, global_size)

    def __eq__(self, other) -> bool:
        if not isinstance(other, Buffer):
            return NotImplemented
        return self._inner == other._inner

    def get_event(self) -> Event:
        return Event(_event= self._inner.get_event())

    @property
    def id(self) -> int:
        return self._inner.get_id()
    
    @property
    def size(self) -> int:
        return self._inner.get_size()

class FIFOBuffer(Buffer):
    _inner: ext.FIFOBuffer

    def __init__(self, id: int = 0, size: int = 0, kernels_in: List[int] = [], kernels_out: List[int] = [], _buffer: ext.FIFOBuffer = None):
        if _buffer is not None:
            self._inner = _buffer
        else:
            assert size > 0, "Buffer size must be greater than 0"
            self._inner = ext.FIFOBuffer.create(id, size, kernels_in, kernels_out)

