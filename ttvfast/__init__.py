# -*- coding: utf-8 -*-

"Fast TTV computation"

from ._ttvfast import _ttvfast as _ttvfast_fn
from . import models


__all__ = ['ttvfast']


def ttvfast(planets, stellar_mass, time, dt, total, rv_times=None, input_flag=0):
    '''
    Run the TTV fast function. See https://github.com/kdeck/TTVFast.
    Program arguments:
    * planets: list of `models.Planet` instances
    * stellar_mass: stellar mass (solar masses)
    * time: start point for integration (days)
    * dt: time step for the integration (days)
    * total: end point for integration (days)
    * rv_times: rv measurement times
    * input_flag: input coordinate system (0, 1 or 2)

    The `input_flag` argument corresponds to:
        0 = Jacobi
        1 = astrocentric elements
        2 = astrocentric cartesian
    '''
    if input_flag not in [0, 1, 2]:
        raise ValueError('Invalid `input_flag` value. Must be 0, 1 or 2')

    params = models.planets_to_params(stellar_mass, planets)
    n_plan = len(planets)

    len_rv = len(rv_times) if rv_times is not None else 0
    positions, rv = _ttvfast_fn(
        params, dt, time, total, n_plan, input_flag, len_rv, rv_times)
    return {'positions': positions, 'rv': rv}

__all__ = ['ttvfast']
