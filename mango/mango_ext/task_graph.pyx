# distutils: language = c++
#cython: language_level=3

from cython.operator cimport dereference as deref
from libcpp.memory cimport shared_ptr
from libcpp.vector cimport vector
from typing import List

cimport mango.mango_ext.task_graph as task_graph
from mango.mango_ext.task_graph cimport cTaskGraph
from mango.mango_ext.event cimport Event
from mango.mango_ext.buffer cimport Buffer
from mango.mango_ext.kernel cimport Kernel

cdef class TaskGraph:
    def __dealloc__(self):
        if self.ptr_owner:
            del self.ptr

    @staticmethod
    def create() -> TaskGraph:
        tg = TaskGraph()
        tg.ptr = new cTaskGraph()
        tg.ptr_owner = True
        return tg

    @staticmethod
    def create_full(kernels: List[Kernel], buffers: List[Buffer], events: List[Event]) -> TaskGraph:
        cdef vector[shared_ptr[cKernel]] kernels_v
        cdef vector[shared_ptr[cBuffer]] buffers_v
        cdef vector[shared_ptr[cEvent]] events_v
        cdef Kernel _k
        cdef Buffer _b
        cdef Event _e
        for k in kernels:
            _k = k
            kernels_v.push_back(_k.ptr)
        for b in buffers:
            _b = b
            buffers_v.push_back(_b.ptr)
        for e in events:
            _e = e
            events_v.push_back(_e.ptr)
        tg = TaskGraph()
        tg.ptr = new cTaskGraph(kernels_v, buffers_v, events_v)
        tg.ptr_owner = True
        return tg

    @staticmethod
    cdef TaskGraph from_ptr(cTaskGraph *ptr):
        obj = TaskGraph()
        obj.ptr = ptr
        obj.ptr_owner = False
        return obj

    def add_kernel(self, kernel: Kernel) -> None:
       self.ptr = &task_graph.add_kernel(deref(self.ptr), kernel.ptr)

    def remove_kernel(self, kernel: Kernel) -> None:
       self.ptr = &task_graph.remove_kernel(deref(self.ptr), kernel.ptr)

    def add_buffer(self, buffer: Buffer) -> None:
       self.ptr = &task_graph.add_buffer(deref(self.ptr), buffer.ptr)

    def remove_buffer(self, buffer: Buffer) -> None:
       self.ptr = &task_graph.remove_buffer(deref(self.ptr), buffer.ptr)

    def add_event(self, event: Event) -> None:
        self.ptr = &task_graph.add_event(deref(self.ptr), event.ptr)

    def remove_event(self, event: Event) -> None:
        self.ptr = &task_graph.remove_event(deref(self.ptr), event.ptr)
