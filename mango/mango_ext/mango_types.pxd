# distutils: language = c++
# cython: language_level = 3

from libc.stdint cimport uint32_t, uint64_t
from libcpp.memory cimport shared_ptr
from libcpp cimport bool

cdef extern from "mango_types.h" namespace "mango":

    ctypedef uint32_t mango_id_t
    ctypedef uint32_t mango_size_t

    cdef enum cMangoEventStatus "mango::MangoEventStatus":
        MangoEventStatus_LOCK "mango::LOCK", 
        MangoEventStatus_READ "mango::READ", 
        MangoEventStatus_WRITE "mango::WRITE", 
        MangoEventStatus_END_FIFO_OPERATION "mango::END_FIFO_OPERATION"

    ctypedef cMangoEventStatus mango_event_status_t

    cdef cppclass cExitCode "mango::ExitCode":
        pass

    ctypedef cExitCode mango_exit_code_t

    cdef cppclass cBufferType "mango::BufferType":
        pass

    ctypedef cBufferType mango_buffer_type_t

    cdef cppclass cUnitType "mango::UnitType":
        pass

    ctypedef cUnitType mango_unit_type_t

    cdef cppclass cFileType "mango::FileType":
        pass
    
    ctypedef cFileType mango_file_type_t

    cdef cppclass cMemoryBank "mango::MemoryBank":
        cMemoryBank(mango_id_t id, mango_size_t phy_addr, mango_size_t size, mango_id_t tile)
        mango_id_t get_id() const
        mango_size_t get_phy_addr() const
        mango_size_t get_size() const
        mango_id_t get_tile() const

    cdef cppclass cUnit "mango::Unit":
        cUnit(mango_id_t id, cUnitType arch, int nr_cores)
        mango_id_t get_id() const
        mango_unit_type_t get_arch() const
        int get_nr_cores() const

cdef extern from "mango_types.h" namespace "mango::ExitCode":
    cdef cExitCode ExitCode_SUCCESS "mango::ExitCode::SUCCESS",
    cdef cExitCode ExitCode_ERR_INVALID_VALUE "mango::ExitCode::ERR_INVALID_VALUE",
    cdef cExitCode ExitCode_ERR_INVALID_TASK_ID "mango::ExitCode::ERR_INVALID_TASK_ID",
    cdef cExitCode ExitCode_ERR_INVALID_KERNEL "mango::ExitCode::ERR_INVALID_KERNEL",
    cdef cExitCode ExitCode_ERR_FEATURE_NOT_IMPLEMENTED "mango::ExitCode::ERR_FEATURE_NOT_IMPLEMENTED",
    cdef cExitCode ExitCode_ERR_INVALID_KERNEL_FILE "mango::ExitCode::ERR_INVALID_KERNEL_FILE",
    cdef cExitCode ExitCode_ERR_UNSUPPORTED_UNIT "mango::ExitCode::ERR_UNSUPPORTED_UNIT",
    cdef cExitCode ExitCode_ERR_OUT_OF_MEMORY "mango::ExitCode::ERR_OUT_OF_MEMORY",
    cdef cExitCode ExitCode_ERR_SEM_FAILED "mango::ExitCode::ERR_SEM_FAILED",
    cdef cExitCode ExitCode_ERR_MMAP_FAILED "mango::ExitCode::ERR_MMAP_FAILED",
    cdef cExitCode ExitCode_ERR_FOPEN "mango::ExitCode::ERR_FOPEN",
    cdef cExitCode ExitCode_ERR_OTHER "mango::ExitCode::ERR_OTHER"

cdef inline int exit_code_to_int(cExitCode code):
    return <int>code

cdef extern from "mango_types.h" namespace "mango::BufferType":
    cdef cBufferType BufferType_NONE "mango::BufferType::NONE",
    cdef cBufferType BufferType_FIFO "mango::BufferType::FIFO",
    cdef cBufferType BufferType_BUFFER "mango::BufferType::BUFFER",
    cdef cBufferType BufferType_SCALAR "mango::BufferType::SCALAR"

cdef inline int buffer_type_to_int(cBufferType type):
    return <int>type

cdef extern from "mango_types.h" namespace "mango::UnitType":
    cdef cUnitType UnitType_PEAK "mango::UnitType::PEAK",
    cdef cUnitType UnitType_NUP "mango::UnitType::NUP",
    cdef cUnitType UnitType_DCT "mango::UnitType::DCT",
    cdef cUnitType UnitType_GN "mango::UnitType::GN",
    cdef cUnitType UnitType_GPU "mango::UnitType::GPU",
    cdef cUnitType UnitType_ARM "mango::UnitType::ARM",
    cdef cUnitType UnitType_STOP "mango::UnitType::STOP"

cdef inline int unit_type_to_int(cUnitType type):
    return <int>type

cdef extern from "mango_types.h" namespace "mango::FileType":
    cdef cFileType FileType_UNKNOWN_KERNEL_SOURCE_TYPE "mango::FileType::UNKNOWN_KERNEL_SOURCE_TYPE",
    cdef cFileType FileType_BINARY "mango::FileType::BINARY",
    cdef cFileType FileType_HARDWARE "mango::FileType::HARDWARE", 
    cdef cFileType FileType_STRING "mango::FileType::STRING",
    cdef cFileType FileType_SOURCE "mango::FileType::SOURCE"

cdef inline int file_type_to_int(cFileType type):
    return <int>type

cdef class Unit:
    cdef shared_ptr[cUnit] ptr

    @staticmethod
    cdef Unit from_ptr(shared_ptr[cUnit] ptr)
