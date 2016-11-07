# -*- coding: utf-8 -*-

"Fast TTV computation"

from ._ttvfast import _ttvfast as _ttvfast_fn
from . import models
from .version import __version__  # noqa
try:
    from typing import List, Dict, Any, Optional  # noqa: F401
except ImportError:
    pass


__all__ = ['ttvfast']  # type: List[str]


def ttvfast(planets,  # type: List[models.Planet]
            stellar_mass,  # type: float
            time,  # type: float
            dt,  # type: float
            total,  # type: float
            rv_times=None,  # type: Optional[List[float]]
            input_flag=0  # type: int
            ):
    # type: (...) -> Dict[str, List[float]]
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
