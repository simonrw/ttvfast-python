# -*- coding: utf-8 -*-

"Fast TTV computation"


__all__ = ['ttvfast']


from collections import namedtuple
import numpy as np
from ._ttvfast import _ttvfast as _ttvfast_fn
from . import models

TTVFastResult = namedtuple('TTVFastResult', [
    'planets', 'epochs', 'times', 'rsky', 'vsky', 'rv',
])

__all__ = ['ttvfast']


def ttvfast(planets, stellar_mass, time, dt, total, rv_times=None):
    '''
    Run the TTV fast function. See https://github.com/kdeck/TTVFast.
    Program arguments:
    * planets: list of `models.Planet` instances
    * stellar_mass: stellar mass (solar masses)
    * time: start point for integration (days)
    * dt: time step for the integration (days)
    * total: end point for integration (days)
    * rv_times: rv measurement times
    '''
    params = models.planets_to_params(stellar_mass, planets)
    n_plan = len(planets)
    input_flag = 0

    len_rv = len(rv_times) if rv_times is not None else 0
    positions, rv = _ttvfast_fn(params, dt, time, total, n_plan, input_flag, len_rv, rv_times)

    return TTVFastResult(
        planets=np.array(positions[0]),
        epochs=np.array(positions[1]),
        times=np.array(positions[2]),
        rsky=np.array(positions[3]),
        vsky=np.array(positions[4]),
        rv=np.array(rv) if rv else None,
    )

__all__ = ['ttvfast']
