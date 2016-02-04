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


Usage
=====

To compute the TTV properties for one or more planets: 

- build a ``ttvfast.models.Planet`` instance (see the class documentation for required parameters)
- pass a list of the planets in the system to ``ttvfast.ttvfast`` along with:

  - the stellar mass in units of solar mass,
  - the start point of the integration in days,
  - the time step for the integration in days,
  - and the end point for integration in days.

The function ``ttvfast.ttvfast`` returns a dictionary containing ``positions`` and ``rv``. The ``positions`` entry is a tuple of:

1. a list of integer indices for which values correspond to which planet,
2. a list of integers defining the epoch,
3. a list of times,
4. a list of rsky values, and
5. a list of vsky values.

The optional ``rv_times`` parameter takes a list of RV times on which the RV is to be calculated. If so the ``rv`` entry in the output 
dictionary is populated with a list of RV values, and otherwise ``None``.

For more details, see the original C module's documentation: https://github.com/kdeck/TTVFast/blob/master/c_version/README
