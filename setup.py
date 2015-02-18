# -*- coding: utf-8 -*-


from setuptools import setup, Extension
import numpy 

ttvfast = Extension("ttvfast", 
            sources=["ttvfast_wrapper.c", "./TTVFast/c_version/TTVFast.c"],
            include_dirs=['TTVFast/c_version', numpy.get_include()],
            # Debug mode
            # define_macros=[('DEBUG', True)],
            )

setup(
        name='ttvfast',
        ext_modules=[ttvfast, ],
        )
