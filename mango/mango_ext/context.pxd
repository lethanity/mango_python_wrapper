# distutils: language = c++
# cython: language_level = 3

from libcpp.memory cimport shared_ptr
from libcpp.map cimport map
from libcpp.vector cimport vector
from libc.stdint cimport uint16_t
from libcpp.string cimport string

from mango.mango_ext.kernel cimport cKernel
from mango.mango_ext.buffer cimport cBuffer
from mango.mango_ext.event cimport cEvent
from mango.mango_ext.kernel_arguments cimport cKernelArguments
from mango.mango_ext.kernel_function cimport cKernelFunction
from mango.mango_ext.task_graph cimport cTaskGraph
from mango.mango_ext.mango_types cimport mango_id_t, mango_exit_code_t

cdef extern from "context.h" namespace "mango":
    cdef cppclass cContext "mango::Context":
        mango_exit_code_t resource_allocation(cTaskGraph &tg)
        mango_exit_code_t resource_deallocation(cTaskGraph &tg)
        shared_ptr[cEvent] start_kernel(shared_ptr[cKernel] kernel, cKernelArguments &args, shared_ptr[cEvent] event)
    
        shared_ptr[cKernel] register_kernel(mango_id_t kid, cKernelFunction *k, vector[mango_id_t] in_buffers, vector[mango_id_t] out_buffers)

        shared_ptr[cBuffer] register_buffer(shared_ptr[cBuffer] the_buffer, mango_id_t bid)

        void deregister_buffer(mango_id_t bid)

        shared_ptr[cEvent] register_event(shared_ptr[cEvent] event)
        shared_ptr[cKernel] get_kernel(mango_id_t id)
        shared_ptr[cBuffer] get_buffer(mango_id_t id)
        shared_ptr[cEvent] get_event(mango_id_t id)

        map[mango_id_t, shared_ptr[cEvent]] & get_events() const
        @staticmethod
        uint16_t mango_get_max_nr_buffers()
        @staticmethod
        size_t get_max_nr_resources()

    cdef cppclass cBBQContext "mango::BBQContext"(cContext) :
        cBBQContext(const string  & _name, const string  & _recipe)

cdef extern from "context_wrap.h" namespace "mango":
    cContext & add_kernel(cContext& ctx, shared_ptr[cKernel] k)
    cContext & add_buffer(cContext& ctx, shared_ptr[cBuffer] b)
    cContext & add_event(cContext& ctx, shared_ptr[cEvent] e)

cdef class Context:
    cdef cContext *ptr