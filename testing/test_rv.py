import numpy as np
import ttvfast

def test_rv_given(stellar_mass, planets, python_args):
    rv_times = [475.40947, 481.50789, 505.56661, 508.60654, 514.56435, 533.36529,
                537.45558, 551.44399, 582.35976, 597.30019, 611.24418, ]

    expected = [ -4.557399570827615e-07, -2.664545469316134e-05, -2.023759760196753e-05,
                -2.300427585052538e-06, 2.900816865436315e-05, 1.477347050308233e-05,
                2.907887313600428e-05, -1.322952680464436e-05, 2.874508640612880e-05,
                -5.481921572024111e-06, -1.876024000347331e-05, ]

    Time, dt, Total = python_args
    results = ttvfast.ttvfast(planets, stellar_mass, Time, dt, Total, rv_times=rv_times)
    assert np.allclose(results['rv'], expected)


def test_no_rv_given(stellar_mass, planets, python_args):
    Time, dt, Total = python_args
    results = ttvfast.ttvfast(planets, stellar_mass, Time, dt, Total)
    assert results['rv'] is None

