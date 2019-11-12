from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

# TODO dont hardcode installation path
extensions = [
    Extension("mango_wrapper", ["mango_wrapper.pyx"],
        include_dirs=['/opt/mango/include/libmango/host'],
        libraries=['mango'],
        library_dirs=['/opt/mango/lib']),
]
setup(
    name="Mango wrapper",
    ext_modules=cythonize(extensions),
)
