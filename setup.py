# -*- coding: utf-8 -*-


from setuptools import setup, Extension
from codecs import open
from os import path

here = path.abspath(path.dirname(__file__))

ttvfast = Extension("ttvfast._ttvfast",
            sources=["src/ttvfast_wrapper.c",
                "external/TTVFast/c_version/TTVFast.c"],
            include_dirs=['external/TTVFast/c_version'],
            extra_compile_args=['-std=c99'],
            # Debug mode
            # define_macros=[('DEBUG', True)],
            )

with open(path.join(here, 'README.rst'), encoding='utf-8') as infile:
    long_description = infile.read()

setup(
    name='ttvfast',
    version='0.2.0',
    description='Python wrapper to ttvfast',
    url='https://github.com/mindriot101/ttvfast-python',
    long_description=long_description,
    author='Simon Walker',
    author_email='s.r.walker101@googlemail.com',
    license='GPL',
    packages=['ttvfast', ],
    ext_modules=[ttvfast, ],
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Intended Audience :: Science/Research',
        'License :: OSI Approved :: GNU General Public License v2 (GPLv2)',
        'Topic :: Scientific/Engineering :: Physics',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.6',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
    ],
)
