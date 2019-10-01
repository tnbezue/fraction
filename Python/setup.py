from distutils.core import setup, Extension
setup(name="fraction", version="1.0",
      ext_modules=[Extension("fraction", ["fraction.c"])])
