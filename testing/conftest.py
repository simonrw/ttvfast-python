import pytest
from ttvfast import models


@pytest.fixture
def args():
    params = [
        0.000295994511,
        0.95573417954,
        0.00002878248,
        1.0917340278625494e+01,
        5.6159310042858110e-02,
        9.0921164935951211e+01,
        -1.1729336712101943e-18,
        1.8094838714599581e+02,
        -8.7093652691581923e+01,
        0.00061895914,
        2.2266898036209028e+01,
        5.6691301931178648e-02,
        8.7598285693573246e+01,
        4.6220554014026838e-01,
        1.6437004273382669e+00,
        -1.9584857031843157e+01]

    Time = -1045
    dt = 0.54
    Total = 1700
    n_plan = 2
    input_flag = 0

    return params, Time, dt, Total, n_plan, input_flag


@pytest.fixture
def python_args(args):
    params, Time, dt, Total, n_plan, input_flag = args
    return Time, dt, Total


@pytest.fixture
def params():
    return {'mass': 0.00002878248,
            'period': 1.0917340278625494e+01,
            'eccentricity': 5.6159310042858110e-02,
            'inclination': 9.0921164935951211e+01,
            'longnode': -1.1729336712101943e-18,
            'argument': 1.8094838714599581e+02,
            'mean_anomaly': -8.7093652691581923e+01}

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
