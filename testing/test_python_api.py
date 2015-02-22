import numpy as np
import pytest

from ttvfast import models
import ttvfast


@pytest.fixture
def planets():
    stellar_mass = 0.95573417954
    planet1_params = [0.00002878248,
                      1.0917340278625494e+01, 5.6159310042858110e-02,
                      9.0921164935951211e+01, -1.1729336712101943e-18,
                      1.8094838714599581e+02, -8.7093652691581923e+01,
                      ]
    planet2_params = [0.00061895914,
                      2.2266898036209028e+01, 5.6691301931178648e-02,
                      8.7598285693573246e+01, 4.6220554014026838e-01,
                      1.6437004273382669e+00, -1.9584857031843157e+01,
                      ]
    planet1 = models.Planet(*planet1_params)
    planet2 = models.Planet(*planet2_params)
    return [planet1, planet2]


@pytest.fixture
def stellar_mass():
    return 0.95573417954


def test_python_call(stellar_mass, planets, python_args):
    Time, dt, Total = python_args
    results = ttvfast.ttvfast(planets, stellar_mass, dt, Time, Total)

    python_rows = zip(*results)

    with open('testing/example_output.txt') as infile:
        for i, (python_row, c_row) in enumerate(
                zip(python_rows, infile)):
            c_row = c_row.strip().split()
            vals = (int(c_row[0]),
                    int(c_row[1]),
                    float(c_row[2]),
                    float(c_row[3]),
                    float(c_row[4]))
            assert np.allclose(vals, python_row)

    assert i == 374


def test_module_docstring_is_present():
    assert 'Fast TTV computation' in ttvfast.__doc__


def test_ttvfast_docstring_is_present():
    assert 'https://github.com/kdeck/TTVFast' in ttvfast.ttvfast.__doc__
