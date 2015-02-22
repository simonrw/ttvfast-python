# -*- coding: utf-8 -*-

"Fast TTV computation"


from ._ttvfast import _ttvfast as _ttvfast_fn


def ttvfast(params, time, dt, total, n_plan, input_flag):
    '''
    Run the TTV fast function. See https://github.com/kdeck/TTVFast.
    Program arguments:
    * params: parameter list
    * dt: time step for the integration (days)
    * time: start point for integration (days)
    * total: end point for integration (days)
    * n_plan: number of planets to simulate
    * input_flag:
        0: params are Jacobi elements
        1: params are astrocentric elements
        2: params are astrocentric Cartesian
    '''
    return _ttvfast_fn(params, time, dt, total, n_plan, input_flag)
