from ttvfast import _ttvfast
import numpy as np
import pytest
from six.moves import range


def test_ttvfast_main_function(args):
    params, Time, dt, Total, n_plan, input_flag = args

    results, _ = _ttvfast._ttvfast(params, dt, Time, Total, n_plan, input_flag, 0)
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


def test_convert_to_array(args):
    params, Time, dt, Total, n_plan, input_flag = args

    results = _ttvfast._ttvfast(params, dt, Time, Total, n_plan, input_flag, 0)
    rows = list(map(np.array, results))
    assert hasattr(rows[0], 'size')


def test_run_multiple_times(args):
    out = []
    for i in range(10):
        params, Time, dt, Total, n_plan, input_flag = args
        results, _ = _ttvfast._ttvfast(params, dt, Time, Total, n_plan, input_flag, 0)
        out.append(results)

        assert all([len(column) > 0 for column in results])

    assert len(out) == 10
