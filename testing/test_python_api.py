import pytest
import numpy as np

import ttvfast


def test_python_call(stellar_mass, planets, python_args):
    Time, dt, Total = python_args
    results = ttvfast.ttvfast(planets, stellar_mass, Time, dt, Total)

    python_rows = zip(*results['positions'])

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


@pytest.mark.parametrize('input_flag', [-1, -100, 3, 4, 5, 100])
def test_bad_input_flags(stellar_mass, planets, python_args, input_flag):
    Time, dt, Total = python_args
    with pytest.raises(ValueError) as exc_info:
        ttvfast.ttvfast(planets, stellar_mass, Time, dt, Total, input_flag=input_flag)

    assert 'invalid `input_flag`' in str(exc_info).lower()
