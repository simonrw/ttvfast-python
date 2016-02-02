=======
TTVFast
=======
:Author: Simon Walker <s.r.walker101@googlemail.com>

Installation
============

Either download and compile the code with

    ``python setup.py build_ext --inplace``

or install with pip:

    ``pip install git+https://github.com/mindriot101/ttvfast.git``

or clone from git:

```
git clone https://github.com/mindriot101/ttvfast-python.git
cd ttvfast-python
git submodule init
git submodule update # grabs code from TTVFast 
```


Usage
=====

To compute the TTV properties for one or more planets: 

- build a ``ttvfast.models.Planet`` instance (see the class documentation for required parameters)
- pass a list of the planets in the system to ``ttvfast.ttvfast`` along with:

  - the stellar mass in units of solar mass,
  - the start point of the integration in days,
  - the time step for the integration in days,
  - and the end point for integration in days.

The function ``ttvfast.ttvfast`` returns five lists:

1. a list of integer indices for which values correspond to which planet,
2. a list of integers defining the epoch,
3. a list of times,
4. a list of rsky values, and
5. a list of vsky values.

For more details, see the original C module's documentation: https://github.com/kdeck/TTVFast/blob/master/c_version/README

Currently the RV output portion of ``TTVFast`` is not supported.
