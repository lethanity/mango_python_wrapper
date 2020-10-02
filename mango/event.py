from typing import List, TYPE_CHECKING

import mango.mango_ext.event as ext
if TYPE_CHECKING:
    from mango.kernel import KernelBuilder # Needed to avoid circular imports

class EventBuilder:
    kernels_in: List["KernelBuilder"]
    kernels_out: List["KernelBuilder"]

    def __init__(self, kernels_in: List["KernelBuilder"], kernels_out: List["KernelBuilder"]):
        self.kernels_in = kernels_in
        self.kernels_out = kernels_out

class Event:
    _inner: ext.Event

    def __init__(self, kernels_in: List[int] = [], kernels_out: List[int] = [], _event: ext.Event = None):
        if _event is not None:
            self._inner = _event
        else:
            self._inner = ext.Event.create_from_kernel_list(kernels_in, kernels_out)

    @property
    def id(self) -> int:
        return self._inner.get_id()

    def wait(self) -> None:
        self._inner.wait()

    def wait_state(self, state: int) -> None:
        self._inner.wait_state(state)

    def write(self, state: int) -> None:
        self._inner.write(state)