# distutils: language = c++
# cython: language_level = 3

from libcpp.memory cimport shared_ptr
from cython.operator cimport dereference as deref
from libc.stdint cimport uint32_t
from typing import List

from mango.mango_ext.mango_types cimport mango_id_t, mango_size_t
from mango.mango_ext.mango_types import ExitCode
from mango.mango_ext.buffer cimport cBuffer
from mango.mango_ext.event cimport Event, ConstEvent

cdef class ConstBuffer:

    @staticmethod 
    cdef ConstBuffer from_ptr(shared_ptr[const cBuffer] ptr):
        obj = ConstBuffer()
        obj.const_ptr = ptr
        return obj

    def write(self, buffer: bytearray, global_size: int = 0) -> ConstEvent:
        cdef char [:] view = buffer
        return ConstEvent.from_ptr(deref(self.const_ptr).write(&view[0], global_size))

    def read(self, buffer: bytearray, global_size: int = 0) -> ConstEvent:
        cdef char [:] view = buffer
        return ConstEvent.from_ptr(deref(self.const_ptr).read(&view[0], global_size))

    def is_read_by(self, kid: uint32_t) -> bool:
        return deref(self.const_ptr).isReadBy(kid)

    def __eq__(self, other: Buffer) -> bool:
        return deref(self.const_ptr) == deref(other.const_ptr)

    def get_id(self) -> mango_id_t:
        return deref(self.const_ptr).get_id()

    def get_size(self) -> mango_id_t:
        return deref(self.const_ptr).get_size()

    def get_phy_addr(self) -> mango_size_t:
        return deref(self.const_ptr).get_phy_addr()

    def get_mem_tile(self) -> mango_id_t:
        return deref(self.const_ptr).get_mem_tile()

    def get_kernels_in(self) -> List[int]:
        return deref(self.const_ptr).get_kernels_in()

    def get_kernels_out(self) -> List[int]:
        return deref(self.const_ptr).get_kernels_out()

cdef class Buffer(ConstBuffer):

    @staticmethod
    def create(bid: int, size: int, kernels_in: List[int], kernels_out: List[int]):
        obj = Buffer()
        obj.ptr.reset(new cBuffer(bid, size, kernels_in, kernels_out))
        obj.const_ptr = <shared_ptr[const cBuffer]> obj.ptr
        return obj

    @staticmethod 
    cdef Buffer from_ptr(shared_ptr[cBuffer] ptr):
        obj = Buffer()
        obj.ptr = ptr
        obj.const_ptr = <shared_ptr[const cBuffer]> obj.ptr
        return obj
    
    def is_read_by_host(self) -> bool:
        return deref(self.ptr).isReadByHost()

    def get_event(self) -> Event:
        return Event.from_ptr(deref(self.ptr).get_event())

    def set_phy_addr(self, addr: mango_size_t) -> None:
        deref(self.ptr).set_phy_addr(addr)

    def set_mem_tile(self, tile: mango_id_t) -> None:
        deref(self.ptr).set_mem_tile(tile)
    
    def resize(self, size: mango_size_t) -> ExitCode:
        return ExitCode(<int>deref(self.ptr).resize(size))
    
cdef class FIFOBuffer(Buffer):

    @staticmethod
    def create(bid: int, size: int, kernels_in: List[int], kernels_out: List[int]):
        obj = FIFOBuffer()
        obj.fifo_ptr.reset(new cFIFOBuffer(bid, size, kernels_in, kernels_out))
        obj.ptr = <shared_ptr[cBuffer]> obj.fifo_ptr
        obj.const_ptr = <shared_ptr[const cBuffer]> obj.ptr
        return obj

    @staticmethod 
    cdef FIFOBuffer from_ptr(shared_ptr[cFIFOBuffer] ptr):
        obj = FIFOBuffer()
        obj.fifo_ptr = ptr
        obj.ptr = <shared_ptr[cBuffer]> obj.fifo_ptr
        obj.const_ptr = <shared_ptr[const cBuffer]> obj.ptr
        return obj
