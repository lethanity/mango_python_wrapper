from setuptools import setup, Extension
import sys
import os

# Set up MANGO_ROOT

DEFAULT_MANGO_ROOT = "/opt/mango"

ENV_MANGO_ROOT = os.getenv("MANGO_ROOT")

if ENV_MANGO_ROOT is None:
    print(f"NO MANGO_ROOT ENVIRONMENT VARIABLE SET UP, USING DEFAULT: {DEFAULT_MANGO_ROOT}")
    MANGO_ROOT = DEFAULT_MANGO_ROOT
else:
    MANGO_ROOT = ENV_MANGO_ROOT

# Enable or disable cythonizing by checking for CYTHONIZE FLAG

CYTHONIZE_FLAG = "--cythonize"

if CYTHONIZE_FLAG in sys.argv:
    print("CYTHONIZING EXTENSIONS")
    sys.argv.remove(CYTHONIZE_FLAG)
    CYTHONIZE = True
else:
    CYTHONIZE = False

# Extensions

def build_extension(module_name):
    """
    :param module_name: The name of the extension module to compile.
    When cythonizing, the pxd accompanying the pyx must have the same name and be on the same directory.
    """
    if CYTHONIZE:
        module_src = f"mango/mango_ext/{module_name}.pyx"
    else:
        module_src = f"cythonized/mango/mango_ext/{module_name}.cpp"

    return Extension(f"mango.mango_ext.{module_name}", [module_src], 
        include_dirs=[
            f"{MANGO_ROOT}/include/libmango/host", 
            f"{MANGO_ROOT}/bosp/include/bbque", 
            f"{MANGO_ROOT}/bosp/include", 
            f"{MANGO_ROOT}/include",
            "include"
        ],
        libraries=["mango"],
        library_dirs=[f"{MANGO_ROOT}/lib"],
        extra_compile_args=["-w"]
    )

ext_names = [
    "task_graph",
    "event",
    "kernel",
    "kernel_arguments",
    "kernel_function",
    "buffer",
    "context",
    "mango_types",
    "logger",
]

extensions = [build_extension(e) for e in ext_names]

if CYTHONIZE:
    from Cython.Build import cythonize

    ext_modules = cythonize(
        extensions,
        build_dir="cythonized",
        language_level="3",
    )
else:
    ext_modules = extensions

with open("README.md", "r") as fh:
    long_description = fh.read()

setup(
    name="mango",
    version="0.0.1",
    description="Wrapper for Mango API",
    long_description=long_description,
    long_description_content_type="text/markdown",
    packages=["mango"],
    ext_modules=ext_modules,
    classifiers=[
        "Programming Language :: Python :: 3",
        "Operating System :: POSIX :: Linux",
        "Programming Language :: Cython",
        "Programming Language :: C++",
    ],
    python_requires='>=3.6',
)