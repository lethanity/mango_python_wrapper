from mango.mango_ext.mango_types import ExitCode
import mango.exceptions as exc

def exit_code_to_exception(exc: ExitCode) -> None:
    if exc == ExitCode.SUCCESS: pass
    elif exc == ExitCode.ERR_INVALID_VALUE: raise exc.InvalidValueError
    elif exc == ExitCode.ERR_INVALID_TASK_ID: raise exc.InvalidTaskIdError
    elif exc == ExitCode.ERR_INVALID_KERNEL: raise exc.InvalidKernelError
    elif exc == ExitCode.ERR_FEATURE_NOT_IMPLEMENTED: raise exc.NotImplementedError
    elif exc == ExitCode.ERR_INVALID_KERNEL_FILE: raise exc.InvalidKernelFileError
    elif exc == ExitCode.ERR_UNSUPPORTED_UNIT: raise exc.UnsupportedUnitError
    elif exc == ExitCode.ERR_OUT_OF_MEMORY: raise exc.OutOfMemoryError
    elif exc == ExitCode.ERR_SEM_FAILED: raise exc.SemaphoreFailedError
    elif exc == ExitCode.ERR_MMAP_FAILED: raise exc.MMapFailedError
    elif exc == ExitCode.ERR_FOPEN: raise exc.FileOpenError
    else: raise Exception("Generic mango error")