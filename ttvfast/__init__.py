# -*- coding: utf-8 -*-

"Fast TTV computation"

from collections import namedtuple
import numpy as np
from ._ttvfast import _ttvfast as _ttvfast_fn
from . import models

__all__ = ['ttvfast']

TTVFastResultBase = namedtuple('TTVFastResultBase', [
    'planets', 'epochs', 'times', 'rsky', 'vsky', 'rv',
])


class TTVFastResult(TTVFastResultBase):
    def __len__(self):
        '''Enables the `len` function to work'''
        return self.times.size

    def row(self, index):
        '''Return a single entry into the results array'''
        if index >= len(self):
            raise IndexError(
                "Index {index} out of bounds for array length {length}".format(
                    index=index, length=len(self)))

        arr = [
            self.planets[index],
            self.epochs[index],
            self.times[index],
            self.rsky[index],
            self.vsky[index],
        ]
        if self.rv is not None:
            arr.append(self.rv[index])

        return arr


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
    positions, rv = _ttvfast_fn(params, dt, time, total, n_plan,
                                input_flag, len_rv, rv_times)

    return TTVFastResult(
        planets=np.array(positions[0]),
        epochs=np.array(positions[1]),
        times=np.array(positions[2]),
        rsky=np.array(positions[3]),
        vsky=np.array(positions[4]),
        rv=np.array(rv) if rv else None,
    )

__all__ = ['ttvfast']
