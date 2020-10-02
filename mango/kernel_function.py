import mango.mango_ext.kernel_function as ext
from mango.mango_types import UnitType, FileType
from mango._utils import exit_code_to_exception

class KernelFunction:
    _inner: ext.KernelFunction

    def __init__(self, _kf: ext.KernelFunction = None):
        if _kf is not None:
            self._inner = _kf
        else:
            self._inner = ext.KernelFunction.create()

    def load(self, kernel_file: str, unit_type: UnitType, file_type: FileType) -> None:
        res = self._inner.load(kernel_file, unit_type, file_type)
        exit_code_to_exception(res)