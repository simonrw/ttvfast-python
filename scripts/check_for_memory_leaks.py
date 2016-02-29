#!/usr/bin/env python
# -*- coding: utf-8 -*-

import resource
import numpy as np
import ttvfast
import os
import matplotlib.pyplot as plt

plt.style.use('ggplot')

def build_args():
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

def run_function(Time, dt, Total, params):
    # Taken from lweiss test
    planet1 = ttvfast.models.Planet(*params[2:2+7])
    planet2 = ttvfast.models.Planet(*params[2+7:])

    gravity, stellar_mass = params[0:2]
    planets = [planet1, planet2]

    results = ttvfast.ttvfast(planets, stellar_mass, Time, dt, Total)

def rusage_kb():
    return resource.getrusage(resource.RUSAGE_SELF).ru_maxrss / 1024

def search_for_memory_leaks():
    args = build_args()
    Time, dt, Total = args[1:4]
    dt /= 5.
    params = args[0]

    iteration, rusages = [], []
    total = 0
    for i in range(100):
        before_usage = rusage_kb()
        run_function(Time, dt, Total, params)
        after_usage = rusage_kb()
        diff_usage = after_usage - before_usage
        rusages.append(diff_usage + total)
        total += diff_usage
        iteration.append(i)


    fig, axis = plt.subplots()
    axis.plot(iteration, rusages)
    axis.set(title='Total: %d kb' % rusages[-1])
    plt.show()

if __name__ == '__main__':
    search_for_memory_leaks()
