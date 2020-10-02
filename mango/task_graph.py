from typing import List, Union

import mango.mango_ext.task_graph as ext
from mango.kernel import Kernel
from mango.buffer import Buffer
from mango.event import Event

class TaskGraph:
    _inner: ext.TaskGraph

    def __init__(self, kernels: List[Kernel] = [], buffers: List[Buffer] = [], events: List[Event] = []):
        self._inner = ext.TaskGraph.create_full(
            [k._inner for k in kernels], 
            [b._inner for b in buffers], 
            [e._inner for e in events]
        )

    def _iadd__(self, other: Union[Kernel, Buffer, Event]):
        other_type = type(other)
        if other_type is Kernel:
            self._inner.add_kernel(other._inner)
        elif other_type is Buffer:
            self._inner.add_buffer(other._inner)
        else:
            self._inner.add_event(other._inner)
        return self

    def _isub__(self, other: Union[Kernel, Buffer, Event]):
        other_type = type(other)
        if other_type is Kernel:
            self._inner.remove_kernel(other._inner)
        elif other_type is Buffer:
            self._inner.remove_buffer(other._inner)
        else:
            self._inner.remove_event(other._inner)
        return self