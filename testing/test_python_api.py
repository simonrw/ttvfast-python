import numpy as np
import pytest

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


class TestTTVFastResult(object):

    @pytest.fixture(scope='module')
    def result_with_rv(self):
        return ttvfast.TTVFastResult(
            planets=np.array([0, 1, 0, 1]),
            epochs=np.random.uniform(0., 1., size=4),
            times=np.random.uniform(0., 1., size=4),
            rsky=np.random.uniform(-1., 1., size=4),
            vsky=np.random.uniform(-1., 1., size=4),
            rv=np.random.uniform(-1., 1., size=4),
        )

    @pytest.fixture(scope='module')
    def result_without_rv(self):
        return ttvfast.TTVFastResult(
            planets=np.array([0, 1, 0, 1]),
            epochs=np.random.uniform(0., 1., size=4),
            times=np.random.uniform(0., 1., size=4),
            rsky=np.random.uniform(-1., 1., size=4),
            vsky=np.random.uniform(-1., 1., size=4),
            rv=None,
        )

    def test_get_length(self, result_without_rv):
        assert len(result_without_rv) == 4

    def test_get_row_without_rv(self, result_without_rv):
        keys = ['planets', 'epochs', 'times', 'rsky', 'vsky']
        for i in range(4):
            expected = [getattr(result_without_rv, key)[i] for key in keys]
            assert np.allclose(result_without_rv.row(i), expected)

    def test_get_row_with_rv(self, result_with_rv):
        keys = ['planets', 'epochs', 'times', 'rsky', 'vsky', 'rv']
        for i in range(4):
            expected = [getattr(result_with_rv, key)[i] for key in keys]
            assert np.allclose(result_with_rv.row(i), expected)

    def test_get_invalid_row(self, result_without_rv):
        with pytest.raises(IndexError) as exc_info:
            result_without_rv.row(100)

        assert 'Index 100 out of bounds for array length 4' in str(exc_info)
