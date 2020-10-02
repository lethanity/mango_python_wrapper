from setuptools import setup, Extension
from Cython.Build import cythonize

extensions = [
    Extension("gif_saver.animated_gif_saver", ["gif_saver/animated_gif_saver.pyx"], 
        include_dirs=["gif_saver"],
        libraries=["gif"],
    ),
]

setup(
    name="sample_wrappers",
    ext_modules=cythonize(
        extensions,
        language_level="3",
    ),
)