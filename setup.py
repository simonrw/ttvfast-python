# -*- coding: utf-8 -*-


from setuptools import setup, Extension
import numpy 

ttvfast = Extension("ttvfast.ttvfast",
            sources=["src/ttvfast_wrapper.c",
                "external/TTVFast/c_version/TTVFast.c"],
            include_dirs=['external/TTVFast/c_version', numpy.get_include()],
            # Debug mode
            # define_macros=[('DEBUG', True)],
            )

setup(
        name='ttvfast',
        packages=['ttvfast', ],
        ext_modules=[ttvfast, ],
        )
