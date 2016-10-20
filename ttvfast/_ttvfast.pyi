from typing import Optional, Tuple

def _ttvfast(
        params: List[float],
        dt: float,
        time: float,
        total: float,
        n_plan: int,
        input_flag: int,
        len_rv: int,
        rv_times: Optional[List[float]],
        ) -> Tuple[List[float], Optional[List[float]]]: ...

# vim: ft=python
