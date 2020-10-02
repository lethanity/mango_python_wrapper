# distutils: language = c++
# cython: language_level = 3

from libcpp.string cimport string
from libcpp cimport bool
from libcpp.map cimport map

from mango.mango_ext.mango_types cimport mango_exit_code_t, mango_unit_type_t, mango_size_t, mango_file_type_t

cdef extern from "kernel.h" namespace "mango":
    cdef cppclass cKernelFunction "mango::KernelFunction":
        mango_exit_code_t load(const string &kernel_file, mango_unit_type_t unit, mango_file_type_t type)
        string get_kernel_version(mango_unit_type_t type) const
        void set_kernel_size(mango_unit_type_t type, mango_size_t size)
        mango_size_t get_kernel_size(mango_unit_type_t type) const
        map[mango_unit_type_t, mango_size_t].const_iterator cbegin() const
        map[mango_unit_type_t, mango_size_t].const_iterator cend() const
        bool is_loaded() const
        size_t length() const

cdef class ConstKernelFunction:
    cdef const cKernelFunction *const_ptr

    @staticmethod
    cdef ConstKernelFunction from_ptr(const cKernelFunction *ptr)

cdef class KernelFunction(ConstKernelFunction):
    cdef cKernelFunction *ptr
    cdef bool ptr_owner

    @staticmethod
    cdef KernelFunction from_ptr(cKernelFunction *ptr)
