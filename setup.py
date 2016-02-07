# -*- coding: utf-8 -*-


from setuptools import setup, Extension

ttvfast = Extension("ttvfast._ttvfast",
            sources=["src/ttvfast_wrapper.c",
                "external/TTVFast/c_version/TTVFast.c"],
            include_dirs=['external/TTVFast/c_version'],
            extra_compile_args=['-std=c99'],
            # Debug mode
            # define_macros=[('DEBUG', True)],
            )

setup(
        name='ttvfast',
        version='0.0.1',
        author='Katherine Deck',
        maintainer='Simon Walker',
        maintainer_email='s.r.walker101@googlemail.com',
        packages=['ttvfast', ],
        ext_modules=[ttvfast, ],
        )
