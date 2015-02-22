from ._ttvfast import _ttvfast as _ttvfast_fn


def ttvfast(*args):
    return _ttvfast_fn(*args)

ttvfast.__doc__ = _ttvfast_fn.__doc__
