# distutils: language = c++
# cython: language_level = 3

from libcpp.vector cimport vector
from cpython cimport array
from cython.operator cimport dereference as deref

from gif_saver.animated_gif_saver cimport AnimatedGifSaver

cdef class GifSaver:
    def __cinit__(self, sx: int, sy: int):
        self.ptr = new AnimatedGifSaver(sx, sy)

    def add_frame(self, data, dt: float) -> bool:
        cdef array.array data_v = array.array('B', data)
        return self.ptr.AddFrame(<unsigned char *> data_v.data.as_voidptr, dt)

    def save(self, filename: str) -> bool:
        return self.ptr.Save(filename.encode('UTF-8'))
