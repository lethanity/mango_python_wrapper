import mango.mango_ext.kernel_arguments as ext
from mango.mango_ext.kernel_arguments import ScalarType
from mango.event import Event
from mango.buffer import Buffer
from mango.kernel import Kernel

class Arg:
    _inner: ext.Arg

class ScalarArg(Arg):
    _inner: ext.ScalarArg

    def __init__(self, arg, stype: ScalarType):
        self._inner = ext.ScalarArg.create(arg, stype)

class BufferArg(Arg):
    _inner: ext.BufferArg

    def __init__(self, arg: Buffer):
        self._inner = ext.BufferArg.create(arg._inner)

class EventArg(Arg):
    _inner: ext.EventArg

    def __init__(self, arg: Event):
        self._inner = ext.EventArg.create(arg._inner)

class KernelArguments:
    _inner: ext.KernelArguments

    def __init__(self, kernel: Kernel, *args: Arg):
        self._inner = ext.KernelArguments.create([a._inner for a in args], kernel._inner)
