# distutils: language = c++
# cython: language_level = 3

from libcpp.vector cimport vector
from libcpp.memory cimport shared_ptr
from libcpp cimport bool
from libc.stdint cimport uint32_t

from mango.mango_ext.mango_types cimport mango_id_t, mango_size_t

cdef extern from "event.h" namespace "mango":
    cdef cppclass cEvent "mango::Event":
        cEvent()
        cEvent(mango_id_t kernel_id)
        cEvent(const vector[mango_id_t] &kernel_id_in, const vector[mango_id_t] &kernel_id_out)
        void wait_state(uint32_t state) const
        uint32_t wait() const
        void write(uint32_t value) const
        uint32_t read() const
        bool operator==(const cEvent &other) const
        mango_id_t get_id() const
        mango_size_t get_phy_addr() const
        void set_phy_addr(mango_size_t addr)
        const vector[mango_id_t] &get_kernels_in() const
        const vector[mango_id_t] &get_kernels_out() const
        void set_callback[A,B](A _bbq_notify_callback, B obj, mango_id_t _id)

    cdef cppclass cKernelCompletionEvent "mango::KernelCompletionEvent"(cEvent):
        cKernelCompletionEvent(mango_id_t kernel)

cdef class ConstEvent:
    cdef shared_ptr[const cEvent] const_ptr

    @staticmethod 
    cdef ConstEvent from_ptr(shared_ptr[const cEvent] ptr)

cdef class Event(ConstEvent):
    cdef shared_ptr[cEvent] ptr

    @staticmethod 
    cdef Event from_ptr(shared_ptr[cEvent] ptr)

cdef class KernelCompletionEvent(Event):
    cdef shared_ptr[cKernelCompletionEvent] kernel_completion_ptr

    @staticmethod 
    cdef KernelCompletionEvent from_ptr(shared_ptr[cKernelCompletionEvent] ptr)
