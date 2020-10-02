# distutils: language = c++
# cython: language_level = 3

from cython.operator cimport preincrement as inc, dereference as deref
from libcpp.map cimport map
from typing import Iterator, Tuple

from mango.mango_ext.mango_types import UnitType, FileType, ExitCode
from mango.mango_ext.mango_types cimport mango_unit_type_t, mango_file_type_t, mango_size_t
from mango.mango_ext.kernel cimport cKernelFunction

cdef class ConstKernelFunction:
    @staticmethod
    cdef ConstKernelFunction from_ptr(const cKernelFunction* ptr):
        obj = ConstKernelFunction()
        obj.const_ptr = ptr
        return obj

    def get_kernel_version(self, type: UnitType) -> str:
        return unicode(self.const_ptr.get_kernel_version(<mango_unit_type_t>(<int>type.value)), 'utf-8')

    def get_kernel_size(self, type: UnitType) -> int:
        return self.const_ptr.get_kernel_size(<mango_unit_type_t>(<int>type.value))

    def __iter__(self) -> Iterator[Tuple[UnitType, int]]:
        cdef map[mango_unit_type_t, mango_size_t].const_iterator it = self.const_ptr.cbegin()
        while it != self.const_ptr.cend():
            pair = deref(it)
            yield (UnitType.create(<int>pair.first), <int>pair.second)
            inc(it)

    def is_loaded(self) -> bool:
        return self.const_ptr.is_loaded()

    def length(self) -> int:
        return self.const_ptr.length()


cdef class KernelFunction(ConstKernelFunction):
    def __dealloc__(self):
        if self.ptr_owner:
            del self.ptr

    @staticmethod
    def create() -> KernelFunction:
        kf = KernelFunction()
        kf.ptr = new cKernelFunction()
        kf.const_ptr = <const cKernelFunction*> kf.ptr
        kf.ptr_owner = True
        return kf

    @staticmethod
    cdef KernelFunction from_ptr(cKernelFunction* ptr):
        obj = KernelFunction()
        obj.ptr = ptr
        obj.const_ptr = <const cKernelFunction*> obj.ptr
        obj.ptr_owner = False
        return obj

    def load(self, kernel_file: str, unit: UnitType, type: FileType) -> ExitCode:
        return ExitCode(
            <int>self.ptr.load(
                kernel_file.encode("utf-8"), 
                <mango_unit_type_t>(<int>unit.value), 
                <mango_file_type_t>(<int>type.value)
            )
        )

    def set_kernel_size(self, type: UnitType, size: int) -> None:
        self.ptr.set_kernel_size(<mango_unit_type_t>(<int>type.value), size)