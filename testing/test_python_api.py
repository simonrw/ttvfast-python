import numpy as np

from ttvfast import ttvfast


def test_python_call(args):
    params, Time, dt, Total, n_plan, input_flag = args

    results = ttvfast(params, dt, Time, Total, n_plan, input_flag)
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
