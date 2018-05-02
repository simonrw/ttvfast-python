=======
TTVFast
=======
:Author: Simon Walker <s.r.walker101@googlemail.com>

.. image:: https://img.shields.io/pypi/v/ttvfast.svg?maxAge=2592000
    :target: https://pypi.python.org/pypi/ttvfast
.. image:: https://travis-ci.org/mindriot101/ttvfast-python.svg?branch=master
    :target: https://travis-ci.org/mindriot101/ttvfast-python

A Python wrapper around Katherine Deck's TTVFast C program (https://github.com/kdeck/TTVFast)

For the latest changes, see `the CHANGELOG <https://github.com/mindriot101/ttvfast-python/blob/master/CHANGELOG.rst>`_.


Installation
============

For contributing to the package, see the `Development instructions`_.

Install from pypi:

    ``pip install ttvfast``

For the latest development version, install with pip:

    ``pip install git+https://github.com/mindriot101/ttvfast.git``

Development instructions
------------------------

To contribute to ``ttvfast``, clone the repository and fetch the submodule::

    git clone https://github.com/mindriot101/ttvfast-python.git
    cd ttvfast-python
    git submodule init
    git submodule update # grabs code from TTVFast

install the package, in "development mode" into the current python environment::

    pip install -e .

This way any python code changes made to the current directory will be reflected in the package. Note: any changes to the C code require recompilation by reinstalling the package with ``pip install -e .`` (see the `editable install documentation <https://pip.pypa.io/en/stable/reference/pip_install/#editable-installs>`_ documentation for more information).

Once the package is installed, test that everything built properly using::

    $ py.test 
    ============================== test session starts ===============================
    testing/test_lweiss.py .
    testing/test_models.py ...
    testing/test_python_api.py ...
    testing/test_ttvfast.py ...


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

Citations
=========

If you use this code, please cite Deck, Agol, Holman, & Nesvorny (2014),
ApJ, 787, 132, arXiv:1403.1895.

-Katherine Deck, Eric Agol, Matt Holman, & David Nesvorny
