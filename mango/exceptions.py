class FileOpenError(OSError):
    def __init__(self):
        super().__init__("File open failure")

class MMapFailedError(RuntimeError):
    def __init__(self):
        super().__init__("mmap failure")

class SemaphoreFailedError(RuntimeError):
    def __init__(self):
        super().__init__("Semaphore open failure")

class OutOfMemoryError(MemoryError):
    def __init__(self):
        super().__init__("Out of memory")

class UnsupportedUnitError(ValueError):
    def __init__(self):
        super().__init__("Unit type not supported in current configuration")

class InvalidKernelFileError(ValueError):
    def __init__(self):
        super().__init__("Kernel file is of an unknown or invalid type")

class InvalidKernelError(ValueError):
    def __init__(self):
        super().__init__("Invalid kernel structure")

class InvalidTaskIdError(ValueError):
    def __init__(self):
        super().__init__("Invalid task id")

class InvalidValueError(ValueError):
    def __init__(self):
        super().__init__("Invalid value")
