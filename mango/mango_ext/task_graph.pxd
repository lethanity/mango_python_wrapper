# distutils: language = c++
# cython: language_level = 3

from libcpp.vector cimport vector
from libcpp.memory cimport shared_ptr
from libcpp cimport bool

from mango.mango_ext.kernel cimport cKernel
from mango.mango_ext.buffer cimport cBuffer
from mango.mango_ext.event cimport cEvent
from mango.mango_ext.mango_types cimport mango_id_t

cdef extern from "task_graph.h" namespace "mango":
    cdef cppclass cTaskGraph "mango::TaskGraph":
        cTaskGraph()
        cTaskGraph(vector[shared_ptr[cKernel]] lkernels, vector[shared_ptr[cBuffer]] lbuffers, vector[shared_ptr[cEvent]] levents)
        
        shared_ptr[cKernel] get_kernel_by_id(mango_id_t id)
        vector[shared_ptr[cKernel]] & get_kernels()
        vector[shared_ptr[cBuffer]] & get_buffers()
        vector[shared_ptr[cEvent]] & get_events() 

cdef extern from "task_graph_wrap.h" namespace "mango":
    cTaskGraph & add_kernel(cTaskGraph &tg, shared_ptr[cKernel] kernel)
    cTaskGraph & remove_kernel(cTaskGraph &tg, shared_ptr[cKernel] kernel)
    cTaskGraph & add_buffer(cTaskGraph &tg, shared_ptr[cBuffer] buffer)
    cTaskGraph & remove_buffer(cTaskGraph &tg, shared_ptr[cBuffer] buffer)
    cTaskGraph & add_event(cTaskGraph &tg, shared_ptr[cEvent] event)
    cTaskGraph & remove_event(cTaskGraph &tg, shared_ptr[cEvent] event)

cdef class TaskGraph:
    cdef cTaskGraph *ptr
    cdef bool ptr_owner

    @staticmethod
    cdef TaskGraph from_ptr(cTaskGraph *ptr)
