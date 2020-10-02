# Python wrapper for Mango API

**Install**
```bash
$ pip3 install .
```

**Uninstall**
```bash
$ pip3 uninstall mango
```

## Development

**Setup**
```bash
$ pipenv install
$ pipenv shell
```

All commands listed after these are assumed to be running under the pipenv shell, or with `pipenv run`

**Packaging**
```bash
$ python setup.py bdist_wheel # --cythonize if you wish to recompile extensions
```

**Install from packaged distribution**
Once you run the packaging command, the packaged module will be saved in the dist directory. To install it:
```bash
$ pip3 install dist/mango-$VERSION-$TAGS.whl
```

**Only compile extensions**
```bash
$ python setup.py build_ext # --cythonize if you wish to recompile extensions
```

**Test**
To run the tests, either the mango module needs to be installed, or the extensions need to be compiled.
Also to run the gif_fifo and gif_animation samples, the wrapper for **gif_saver** needs to be compiled. It is found under `tests/sample_wrappers`.

```bash
# Replace $TEST_FILENAME with the filename of the test you wish to run
$ python -m tests.$TEST_FILENAME
```

**Conventions**

- No regular `__init__` or `__cinit__` constructors are used for extension classes
- Extension class object construction is done via factory functions provided as staticmethods of each corresponding class
- Regular pointers (\*) must be deleted manually if they are created by the class
- Regular pointers (\*) are **NOT** deleted when the class is created from an existing pointer
- `ptr_owner` indicates if the class created the pointer, in which case it should be deleted on `__dealloc__`
- `shared_ptr` properties are created and deallocated automatically by cython
