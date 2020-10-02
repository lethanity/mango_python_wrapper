# distutils: language = c++
# cython: language_level = 3

from libcpp.memory cimport shared_ptr
from libcpp.vector cimport vector
from libc.stdint cimport uint32_t
from libcpp cimport bool

from mango.mango_ext.event cimport cEvent
from mango.mango_ext.mango_types cimport mango_id_t, mango_size_t, mango_exit_code_t

cdef extern from "buffer.h" namespace "mango":
    cdef cppclass cBuffer "mango::Buffer":
        cBuffer(mango_id_t bid, mango_size_t size, const vector[mango_id_t] &kernels_in, const vector[mango_id_t] &kernels_out)
        shared_ptr[const cEvent] write(const void *GN_buffer, mango_size_t global_size) const
        shared_ptr[const cEvent] read(void *GN_buffer, mango_size_t global_size) const
        bool isReadByHost()
        bool isReadBy(uint32_t kid) const
        bool operator==(const cBuffer &other) const
        mango_exit_code_t resize(mango_size_t size)
        mango_id_t get_id() const
        mango_id_t get_size() const
        mango_size_t get_phy_addr() const
        mango_id_t get_mem_tile() const
        void set_phy_addr(mango_size_t addr)
        void set_mem_tile(mango_id_t tile)
        shared_ptr[cEvent] get_event()
        const vector[mango_id_t] &get_kernels_in() const
        const vector[mango_id_t] &get_kernels_out() const
    
    cdef cppclass cFIFOBuffer "mango::FIFOBuffer"(cBuffer):
        cFIFOBuffer(mango_id_t bid, mango_size_t size, const vector[mango_id_t] &kernels_in, const vector[mango_id_t] &kernels_out)


cdef class ConstBuffer:
    cdef shared_ptr[const cBuffer] const_ptr

    @staticmethod 
    cdef ConstBuffer from_ptr(shared_ptr[const cBuffer] ptr)

cdef class Buffer(ConstBuffer):
    cdef shared_ptr[cBuffer] ptr
    
    @staticmethod 
    cdef Buffer from_ptr(shared_ptr[cBuffer] ptr)

cdef class FIFOBuffer(Buffer):
    cdef shared_ptr[cFIFOBuffer] fifo_ptr

    @staticmethod 
    cdef FIFOBuffer from_ptr(shared_ptr[cFIFOBuffer] ptr)
