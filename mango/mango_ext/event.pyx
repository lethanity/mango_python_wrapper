# distutils: language = c++
# cython: language_level=3

from cython.operator cimport dereference as deref
from libcpp.memory cimport shared_ptr
from libcpp.vector cimport vector
from typing import List

from mango.mango_ext.event cimport cEvent

cdef class ConstEvent:

    @staticmethod 
    cdef ConstEvent from_ptr(shared_ptr[const cEvent] ptr):
        obj = ConstEvent()
        obj.const_ptr = ptr
        return obj

    def wait_state(self, state: uint32_t) -> None:
        deref(self.const_ptr).wait_state(state)

    def wait(self) -> uint32_t:
        return deref(self.const_ptr).wait()

    def write(self, state: uint32_t) -> None:
        deref(self.const_ptr).write(state)

    def read(self) -> uint32_t:
        return deref(self.const_ptr).read()

    def __eq__(self, other: Event):
        return deref(self.const_ptr) == deref(other.const_ptr)

    def get_id(self) -> uint32_t:
        return deref(self.const_ptr).get_id()

    def get_phy_addr(self) -> uint32_t:
        return deref(self.const_ptr).get_phy_addr()

    def get_kernels_in(self) -> List[int]:
        return deref(self.const_ptr).get_kernels_in()

    def get_kernels_out(self) -> List[int]:
        return deref(self.const_ptr).get_kernels_out()

cdef class Event(ConstEvent):

    @staticmethod
    def create_from_id(kernel_id: int) -> Event:
        obj = Event()
        obj.ptr.reset(new cEvent(kernel_id))
        obj.const_ptr = <shared_ptr[const cEvent]> obj.ptr
        return obj

    @staticmethod
    def create() -> Event:
        obj = Event()
        obj.ptr.reset(new cEvent())
        obj.const_ptr = <shared_ptr[const cEvent]> obj.ptr
        return obj

    @staticmethod
    def create_from_kernel_list(kernel_id_in: List[int], kernel_id_out: List[int]) -> Event:
        obj = Event()
        obj.ptr.reset(new cEvent(kernel_id_in, kernel_id_out))
        obj.const_ptr = <shared_ptr[const cEvent]> obj.ptr
        return obj

    @staticmethod
    cdef Event from_ptr(shared_ptr[cEvent] ptr):
        obj = Event()
        obj.ptr = ptr
        obj.const_ptr = <shared_ptr[const cEvent]> obj.ptr
        return obj

    def set_phy_addr(self, addr: uint32_t) -> None:
        deref(self.ptr).set_phy_addr(addr)
 
cdef class KernelCompletionEvent(Event):

    @staticmethod
    def create(kernel_id: uint32_t) -> KernelCompletionEvent:
        obj = KernelCompletionEvent()
        obj.kernel_completion_ptr.reset(new cKernelCompletionEvent(kernel_id))
        obj.ptr = <shared_ptr[cEvent]> obj.kernel_completion_ptr
        obj.const_ptr = <shared_ptr[const cEvent]> obj.ptr
        return obj

    @staticmethod 
    cdef KernelCompletionEvent from_ptr(shared_ptr[cKernelCompletionEvent] ptr):
        obj = KernelCompletionEvent()
        obj.kernel_completion_ptr = ptr
        obj.ptr = <shared_ptr[cEvent]> obj.kernel_completion_ptr
        obj.const_ptr = <shared_ptr[const cEvent]> obj.ptr
        return obj
