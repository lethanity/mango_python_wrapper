# distutils: language = c++
# cython: language_level = 3

from libcpp.memory cimport shared_ptr
from libcpp.string cimport string
from libcpp.vector cimport vector

from mango.mango_ext.kernel cimport cKernel
from mango.mango_ext.buffer cimport cBuffer
from mango.mango_ext.event cimport cEvent
from mango.mango_ext.mango_types cimport mango_size_t, mango_id_t, mango_unit_type_t

cdef extern from "kernel_arguments.h" namespace "mango":
    cdef cppclass cArg "mango::Arg":
        mango_size_t get_value()
        mango_size_t get_size()
        mango_id_t get_id()
        void set_value(mango_size_t value)

    cdef cppclass cScalarArg "mango::ScalarArg" [T](cArg) :
        cScalarArg(T arg)

    cdef cppclass cBufferArg "mango::BufferArg" (cArg) :
        cBufferArg(shared_ptr[const cBuffer] arg)

    cdef cppclass cEventArg "mango::EventArg" (cArg) :
        cEventArg(shared_ptr[const cEvent] arg)

    cdef cppclass cKernelArguments "mango::KernelArguments":
        cKernelArguments(const vector[shared_ptr[cArg]] &arguments, shared_ptr[cKernel] kernel)
        int get_nr_args() const
        string get_arguments(mango_unit_type_t arch_type) const


cdef class KernelArguments:
    cdef cKernelArguments *ptr

cdef class Arg:
    cdef shared_ptr[cArg] ptr

cdef class ScalarArg(Arg):
    pass

cdef class BufferArg(Arg):
    cdef shared_ptr[cBufferArg] buffer_arg_ptr

cdef class EventArg(Arg):
    cdef shared_ptr[cEventArg] event_arg_ptr
