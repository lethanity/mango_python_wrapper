# distutils: language = c++
# cython: language_level = 3

cdef extern from "logger.h" namespace "mango":
    void mango_init_logger()