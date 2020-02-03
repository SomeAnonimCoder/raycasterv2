from distutils.core import Extension, setup
from Cython.Build import cythonize

# define an extension that will be cythonized and compiled
ext = [
    Extension(name="field", sources=["field.pyx"]),
    Extension(name="render", sources=["render.pyx"]),
    Extension(name="player", sources=["player.pyx"])
    ]
setup(ext_modules=cythonize(ext, compiler_directives={"language_level":"3"}))