import numpy as np
import pytest

from ttvfast import models
import ttvfast

def check_against_output_file(results):
    '''
    Function to check the output of `ttvfast` with the example output file
    '''
    with open('testing/example_output.txt') as infile:
        for i, c_row in enumerate(infile):
            c_row = c_row.strip().split()
            expected = (
                int(c_row[0]),
                int(c_row[1]),
                float(c_row[2]),
                float(c_row[3]),
                float(c_row[4]),
            )
            result = (results.planets[i],
                      results.epochs[i],
                      results.times[i],
                      results.rsky[i],
                      results.vsky[i])
            assert np.allclose(result, expected)

    assert i == 374


def test_python_call(stellar_mass, planets, python_args):
    Time, dt, Total = python_args
    results = ttvfast.ttvfast(planets, stellar_mass, Time, dt, Total)
    check_against_output_file(results)


def test_module_docstring_is_present():
    assert 'Fast TTV computation' in ttvfast.__doc__


def test_ttvfast_docstring_is_present():
    assert 'https://github.com/kdeck/TTVFast' in ttvfast.ttvfast.__doc__
