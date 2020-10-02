# distutils: language = c++
# cython: language_level = 3

from cython.operator cimport dereference as deref, preincrement as inc
from libcpp.memory cimport shared_ptr
from typing import List

from mango.mango_ext.mango_types cimport mango_id_t, mango_unit_type_t, Unit
from mango.mango_ext.kernel cimport cKernel
from mango.mango_ext.kernel_function cimport KernelFunction, ConstKernelFunction
from mango.mango_ext.event cimport Event, KernelCompletionEvent

cdef class Kernel:

    @staticmethod
    def create(kid: int, k: KernelFunction, buffers_in: List[int], buffers_out: List[int]) -> Kernel:
        cdef vector[mango_id_t] b_in = buffers_in
        cdef vector[mango_id_t] b_out = buffers_out
        obj = Kernel()
        obj.ptr.reset(new cKernel(kid, k.ptr, b_in, b_out))
        return obj

    @staticmethod 
    cdef Kernel from_ptr(shared_ptr[cKernel] ptr):
        obj = Kernel()
        obj.ptr = ptr
        return obj

    def __eq__(self, other: Kernel) -> bool:
        return deref(self.ptr) == deref(other.ptr)

    def is_a_reader(self, buffer_id: mango_id_t) -> bool:
        return deref(self.ptr).is_a_reader(buffer_id)
    
    def is_a_writer(self, buffer_id: mango_id_t) -> bool:
        return deref(self.ptr).is_a_writer(buffer_id)

    def get_termination_event(self) -> KernelCompletionEvent:
        return KernelCompletionEvent.from_ptr(deref(self.ptr).get_termination_event())

    def get_task_events(self) -> List[Event]:
        return [Event.from_ptr(e) for e in deref(self.ptr).get_task_events()]

    def get_mem_tile(self) -> mango_id_t:
        return deref(self.ptr).get_mem_tile()

    def set_mem_tile(self, mem_tile: mango_id_t) -> None:
        deref(self.ptr).set_mem_tile(mem_tile)

    def get_assigned_unit(self) -> Unit:
        return Unit.from_ptr(deref(self.ptr).get_assigned_unit())

    def set_unit(self, unit: Unit) -> None:
        deref(self.ptr).set_unit(unit.ptr)

    def get_kernel(self) -> ConstKernelFunction:
        return ConstKernelFunction.from_ptr(deref(self.ptr).get_kernel())

    def get_id(self) -> mango_id_t:
        return deref(self.ptr).get_id()

    def buffers_in(self):
        cdef vector[mango_id_t].const_iterator it = deref(self.ptr).buffers_in_cbegin()
        while it != deref(self.ptr).buffers_in_cend():
            yield <mango_id_t>deref(it)
            inc(it)

    def buffers_out(self):
        cdef vector[mango_id_t].const_iterator it = deref(self.ptr).buffers_out_cbegin()
        while it != deref(self.ptr).buffers_out_cend():
            yield <mango_id_t>deref(it)
            inc(it)

    def set_thread_count(self, thread_count: int) -> None:
        deref(self.ptr).set_thread_count(thread_count)

    def get_thread_count(self) -> int:
        return deref(self.ptr).get_thread_count()
