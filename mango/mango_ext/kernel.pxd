# distutils: language = c++
# cython: language_level = 3

from libcpp cimport bool
from libcpp.vector cimport vector
from libcpp.memory cimport shared_ptr

from mango.mango_ext.mango_types cimport mango_id_t, cUnit
from mango.mango_ext.buffer cimport cBuffer
from mango.mango_ext.event cimport cEvent, cKernelCompletionEvent
from mango.mango_ext.kernel_function cimport cKernelFunction

cdef extern from "kernel.h" namespace "mango":
    cdef cppclass cKernel "mango::Kernel":
        cKernel(mango_id_t kid, cKernelFunction *k, vector[mango_id_t] buffers_in, vector[mango_id_t] buffers_out)
        bool operator==(const cKernel &other) const
        bool is_a_reader(mango_id_t buffer_id) const
        bool is_a_writer(mango_id_t buffer_id) const
        shared_ptr[cKernelCompletionEvent] get_termination_event()
        vector[shared_ptr[cEvent]] &get_task_events()
        mango_id_t get_mem_tile() const
        void set_mem_tile(mango_id_t mem_tile)
        shared_ptr[cUnit] get_assigned_unit() const
        void set_unit(shared_ptr[cUnit] unit)
        const cKernelFunction *get_kernel() const
        mango_id_t get_id() const
        vector[mango_id_t].const_iterator buffers_in_cbegin() const
        vector[mango_id_t].const_iterator buffers_in_cend() const
        vector[mango_id_t].const_iterator buffers_out_cbegin() const
        vector[mango_id_t].const_iterator buffers_out_cend() const
        void set_thread_count(int thread_count)
        int get_thread_count() const


cdef class Kernel:
    cdef shared_ptr[cKernel] ptr

    @staticmethod 
    cdef Kernel from_ptr(shared_ptr[cKernel] ptr)