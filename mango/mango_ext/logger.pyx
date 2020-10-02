# distutils: language = c++
# cython: language_level = 3

from mango.mango_ext.logger cimport mango_init_logger

def init_logger():
    mango_init_logger()