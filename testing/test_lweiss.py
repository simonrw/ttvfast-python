import pytest
import numpy as np
import ttvfast

'''
Based on a bug report supplied by Laren Weiss
'''

@pytest.mark.skipif(True, reason='Out of date API')
def test_application(args):
    setup = args
    Time, dt, Total = setup[1:4]
    dt /= 5.
    assert Time == -1045
    assert 0.1 < dt < 0.2
    assert Total == 1700

    params = setup[0]

    planet1 = ttvfast.models.Planet(*params[2:2 + 7])
    planet2 = ttvfast.models.Planet(*params[2 + 7:])

    gravity, stellar_mass = params[0:2]
    planets = [planet1, planet2]

    assert 0.9 < stellar_mass < 1.0
    results = ttvfast.ttvfast(planets, stellar_mass, Time, dt, Total)
    python_rows = list(zip(*results['positions']))

    expected = [1, 7, -8.828648752325788e+02, 6.363231859868642e-03,
                4.321183741781629e-02]
    assert np.allclose(python_rows[22], expected)
