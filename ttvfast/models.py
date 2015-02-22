'''
Handle the conversion of the Planet object to the params list which is
required by the C code.

Required arguments are:
    1) G in units of AU^3/day^2/M_sun
    2) MStar in units of M_sun
    3-9) Planetary parameters:
        * Mplanet in units of M_sun
        * Period in days
        * E between 0 and 1
        * I in units of degrees
        * Longnode in units of degrees
        * Argument in units of degrees
        * mean anomaly in units of degrees
'''


def planets_to_params(stellar_mass, planets, G=0.000295994511):
    out = [G, stellar_mass]
    for planet in planets:
        out.extend([getattr(planet, key) for key in Planet.KEYS])
    return out


class Planet(object):

    '''
    Planet class to define each planet in the system.
    '''

    KEYS = ['mass', 'period', 'eccentricity', 'inclination',
            'longnode', 'argument', 'mean_anomaly']

    def __init__(self, mass, period, eccentricity, inclination,
                 longnode, argument, mean_anomaly):
        '''
        Construct a planet. Required arguments are:
            * mass: Mplanet in units of M_sun
            * period: Period in days
            * eccentricity: E between 0 and 1
            * inclination: I in units of degrees
            * longnode: Longnode in units of degrees
            * argument: Argument in units of degrees
            * mean_anomaly: mean anomaly in units of degrees
        '''
        self.mass = mass
        self.period = period
        self.eccentricity = eccentricity
        self.inclination = inclination
        self.longnode = longnode
        self.argument = argument
        self.mean_anomaly = mean_anomaly
