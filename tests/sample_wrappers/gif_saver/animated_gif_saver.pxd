# distutils: language = c++
# cython: language_level = 3

from libcpp cimport bool

cdef extern from "AnimatedGifSaver.cpp":
    pass

cdef extern from "AnimatedGifSaver.h":
    cdef cppclass AnimatedGifSaver:
        AnimatedGifSaver(int sx, int sy)

        bool AddFrame(unsigned char* data,  float dt)

        bool Save(const char* filename)

cdef class GifSaver:
    cdef AnimatedGifSaver *ptr
