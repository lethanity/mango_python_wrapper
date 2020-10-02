# distutils: language = c++
# cython: language_level

from libcpp.vector cimport vector
from cython.operator cimport dereference as deref
from typing import List

from mango.mango_ext.event cimport Event
from mango.mango_ext.context cimport cBBQContext
from mango.mango_ext.kernel_arguments cimport KernelArguments
from mango.mango_ext.kernel_function cimport KernelFunction
from mango.mango_ext.buffer cimport Buffer
from mango.mango_ext.kernel cimport Kernel
from mango.mango_ext.task_graph cimport TaskGraph
from mango.mango_ext.mango_types cimport mango_id_t
from mango.mango_ext.mango_types import ExitCode

cdef class Context:
    def resource_allocation(self, tg: TaskGraph) -> ExitCode:
        return ExitCode(<int>self.ptr.resource_allocation(deref(tg.ptr)))

    def resource_deallocation(self, tg: TaskGraph) -> ExitCode:
        return ExitCode(<int>self.ptr.resource_deallocation(deref(tg.ptr)))

    def start_kernel(self, kernel: Kernel, args: KernelArguments, event: Event) -> Event:
        return Event.from_ptr(self.ptr.start_kernel(kernel.ptr, deref(args.ptr), event.ptr))

    def register_kernel(self, kid: int, k: KernelFunction, in_buffers: List[int], out_buffers: List[int]) -> Kernel:
        cdef vector[mango_id_t] in_b = in_buffers
        cdef vector[mango_id_t] out_b = out_buffers
        return Kernel.from_ptr(self.ptr.register_kernel(kid, k.ptr, in_b, out_b))

    def register_buffer(self, the_buffer: Buffer, bid: int) -> Buffer:
        return Buffer.from_ptr(self.ptr.register_buffer(the_buffer.ptr, <mango_id_t>bid))

    def deregister_buffer(self, bid: int) -> None:
        self.ptr.deregister_buffer(<mango_id_t>bid)

    def register_event(self, event: Event) -> Event:
        return Event.from_ptr(self.ptr.register_event(event.ptr))

    def get_kernel(self, id: int) -> Kernel:
        return Kernel.from_ptr(self.ptr.get_kernel(<mango_id_t>id))
    
    def get_buffer(self, id: int) -> Buffer:
        return Buffer.from_ptr(self.ptr.get_buffer(<mango_id_t>id))

    def get_event(self, id: int) -> Event:
        return Event.from_ptr(self.ptr.get_event(<mango_id_t>id))

    @staticmethod
    def mango_get_max_nr_buffers() -> int:
        return <int>cContext.mango_get_max_nr_buffers()

    @staticmethod
    def get_max_nr_resources() -> int:
        return <int>cContext.get_max_nr_resources()

cdef class BBQContext(Context):

    @staticmethod
    def create(name: str, recipe: str) -> BBQContext:
        obj = BBQContext()
        obj.ptr = <cContext*> new cBBQContext(name.encode('UTF-8'), recipe.encode('UTF-8'))
        return obj

    def __dealloc__(self):
        del self.ptr
