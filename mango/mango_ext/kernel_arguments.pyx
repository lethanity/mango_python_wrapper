# distutils: language = c++
# cython: language_level = 3

from libcpp.vector cimport vector
from typing import List
from enum import Enum

from mango.mango_ext.mango_types import UnitType
from mango.mango_ext.event cimport Event
from mango.mango_ext.buffer cimport Buffer
from mango.mango_ext.kernel cimport Kernel
from mango.mango_ext.kernel_arguments cimport cArg, cEventArg, cBufferArg, cScalarArg, cKernelArguments
from libcpp.memory cimport shared_ptr
from cython.operator cimport dereference as deref

cdef class Arg:

    def get_value(self) -> int:
        return <int>deref(self.ptr).get_value()

    def get_size(self) -> int:
        return <int>deref(self.ptr).get_size()

    def get_id(self) -> int:
        return <int>deref(self.ptr).get_id()

    def set_value(self, value: int) -> None:
        deref(self.ptr).set_value(<mango_size_t>value)

cdef class ScalarArg(Arg):
    """
    ScalarArg uses the base class ptr only since templates aren't supported in python.
    This is fine since the value gets casted to mango_size_t in the cpp constructor anyways.
    We could store the type if we wanted to give the user the ability to retrieve the value.
    """

    @staticmethod
    def create(arg, stype: ScalarType) -> ScalarArg:
        obj = ScalarArg()

        if stype == ScalarType.CHAR:
            obj.ptr.reset(new cScalarArg[char](<char>arg))
        elif stype == ScalarType.UCHAR:
            obj.ptr.reset(new cScalarArg[unsigned char](<unsigned char>arg))
        elif stype == ScalarType.SHORT:
            obj.ptr.reset(new cScalarArg[short](<short>arg))
        elif stype == ScalarType.USHORT:
            obj.ptr.reset(new cScalarArg[unsigned short](<unsigned short>arg))
        elif stype == ScalarType.INT:
            obj.ptr.reset(new cScalarArg[int](<int>arg))
        elif stype == ScalarType.UINT:
            obj.ptr.reset(new cScalarArg[unsigned int](<unsigned int>arg))
        elif stype == ScalarType.FLOAT:
            obj.ptr.reset(new cScalarArg[float](<float>arg))

        return obj

class ScalarType(Enum):
    """Same types as specified in kernel_arguments.cpp."""
    CHAR = 0
    UCHAR = 1
    SHORT = 2
    USHORT = 3
    INT = 4
    UINT = 5
    FLOAT = 6
 

cdef class BufferArg(Arg):

    @staticmethod
    def create(arg: Buffer) -> BufferArg:
        obj = BufferArg()
        obj.buffer_arg_ptr.reset(new cBufferArg(arg.const_ptr))
        obj.ptr = <shared_ptr[cArg]> obj.buffer_arg_ptr
        return obj

cdef class EventArg(Arg):

    @staticmethod
    def create(arg: Event) -> EventArg:
        obj = EventArg()
        obj.event_arg_ptr.reset(new cEventArg(arg.const_ptr))
        obj.ptr = <shared_ptr[cArg]> obj.event_arg_ptr
        return obj

cdef class KernelArguments:

    @staticmethod
    def create(args: List[Arg], kernel: Kernel) -> KernelArguments:
        obj = KernelArguments()
        cdef vector[shared_ptr[cArg]] args_v
        cdef Arg arg
        for a in args:
            arg = a
            args_v.push_back(arg.ptr)
        obj.ptr = new cKernelArguments(args_v, kernel.ptr)
        return obj

    def get_nr_args(self) -> int:
        return self.ptr.get_nr_args()

    def get_arguments(self, arch_type: UnitType) -> str:
        return unicode(self.ptr.get_arguments(<mango_unit_type_t>(<int>arch_type.value)), 'utf-8')

    def __dealloc__(self):
        del self.ptr
