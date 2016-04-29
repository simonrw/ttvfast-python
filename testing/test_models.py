from numpy import allclose, isclose
import pytest

from ttvfast import models


@pytest.fixture
def planet(params):
    planet = models.Planet(**params)
    return planet


def test_planet_construction(params):
    planet = models.Planet(**params)
    for key in params:
        assert isclose(getattr(planet, key),
                       params[key])


def test_planets_to_params(planet):
    stellar_mass = 1.0
    planets = [planet for _ in range(10)]
    params = models.planets_to_params(stellar_mass, planets)
    assert len(params) == 2 + 10 * 7 == 72


def test_planet_conversion_example():
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
    params = models.planets_to_params(stellar_mass, [planet1, planet2])

    expected = [0.000295994511,
                0.95573417954,
                0.00002878248,
                1.0917340278625494e+01, 5.6159310042858110e-02,
                9.0921164935951211e+01, -1.1729336712101943e-18,
                1.8094838714599581e+02, -8.7093652691581923e+01,
                0.00061895914,
                2.2266898036209028e+01, 5.6691301931178648e-02,
                8.7598285693573246e+01, 4.6220554014026838e-01,
                1.6437004273382669e+00, -1.9584857031843157e+01,
                ]
    assert allclose(params, expected)
