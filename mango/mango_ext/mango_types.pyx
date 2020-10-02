# distutils: language = c++
# cython: language_level = 3

from cython.operator cimport dereference as deref
from libc.stdint cimport uint32_t
from libcpp.memory cimport shared_ptr
from enum import Enum

from mango.mango_ext.mango_types cimport (
    cMangoEventStatus as cMES,
    exit_code_to_int as ec_int,
    buffer_type_to_int as bt_int,
    unit_type_to_int as ut_int,
    file_type_to_int as ft_int
)
cimport mango.mango_ext.mango_types as mt
from mango.mango_ext.mango_types cimport cUnit

cdef class Unit:

    @staticmethod
    def create(id: uint32_t, arch: UnitType, nr_cores: int) -> Unit:
        unit = Unit()
        unit.ptr.reset(new cUnit(id, <mt.mango_unit_type_t>(<int>arch.value), nr_cores))
        unit.ptr_owner = True
        return unit

    @staticmethod
    cdef Unit from_ptr(shared_ptr[cUnit] ptr):
        obj = Unit()
        obj.ptr = ptr
        obj.ptr_owner = False
        return obj

    def get_id(self) -> uint32_t:
        return deref(self.ptr).get_id()

    def get_arch(self) -> UnitType:
        return UnitType(<int>deref(self.ptr).get_arch())

    def get_nr_cores(self) -> int:
        return deref(self.ptr).get_nr_cores()


class MangoEventStatus(Enum):
    LOCK = cMES.MangoEventStatus_LOCK
    READ = cMES.MangoEventStatus_READ
    WRITE = cMES.MangoEventStatus_WRITE
    END_FIFO_OPERATION = cMES.MangoEventStatus_END_FIFO_OPERATION

class ExitCode(Enum):
    SUCCESS = ec_int(mt.ExitCode_SUCCESS)
    ERR_INVALID_VALUE = ec_int(mt.ExitCode_ERR_INVALID_VALUE)
    ERR_INVALID_TASK_ID = ec_int(mt.ExitCode_ERR_INVALID_TASK_ID)
    ERR_INVALID_KERNEL = ec_int(mt.ExitCode_ERR_INVALID_KERNEL)
    ERR_FEATURE_NOT_IMPLEMENTED = ec_int(mt.ExitCode_ERR_FEATURE_NOT_IMPLEMENTED)
    ERR_INVALID_KERNEL_FILE = ec_int(mt.ExitCode_ERR_INVALID_KERNEL_FILE)
    ERR_UNSUPPORTED_UNIT = ec_int(mt.ExitCode_ERR_UNSUPPORTED_UNIT)
    ERR_OUT_OF_MEMORY = ec_int(mt.ExitCode_ERR_OUT_OF_MEMORY)
    ERR_SEM_FAILED = ec_int(mt.ExitCode_ERR_SEM_FAILED)
    ERR_MMAP_FAILED = ec_int(mt.ExitCode_ERR_MMAP_FAILED)
    ERR_FOPEN = ec_int(mt.ExitCode_ERR_FOPEN)
    ERR_OTHER = ec_int(mt.ExitCode_ERR_OTHER)

class BufferType(Enum):
    NONE = bt_int(mt.BufferType_NONE)
    FIFO = bt_int(mt.BufferType_FIFO)
    BUFFER = bt_int(mt.BufferType_BUFFER)
    SCALAR = bt_int(mt.BufferType_SCALAR)

class UnitType(Enum):
    PEAK = ut_int(mt.UnitType_PEAK)
    NUP = ut_int(mt.UnitType_NUP)
    DCT = ut_int(mt.UnitType_DCT)
    GN = ut_int(mt.UnitType_GN)
    GPU = ut_int(mt.UnitType_GPU)
    ARM = ut_int(mt.UnitType_ARM)
    STOP = ut_int(mt.UnitType_STOP)

class FileType(Enum):
    UNKNOWN_KERNEL_SOURCE_TYPE = ft_int(mt.FileType_UNKNOWN_KERNEL_SOURCE_TYPE)
    BINARY = ft_int(mt.FileType_BINARY)
    HARDWARE = ft_int(mt.FileType_HARDWARE)
    STRING = ft_int(mt.FileType_STRING)
    SOURCE = ft_int(mt.FileType_SOURCE)
