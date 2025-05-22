from __future__ import annotations

from typing import TypeVar
import json

from pyotherside_utils import *
import cattrs

V = TypeVar('V')

cattrs_safe = lambda name='model': exception_safe({cattrs.ClassValidationError: ExceptionHandlingInfo(name, lambda e: ', '.join(cattrs.transform_error(e)))})

def load_model(_data: str | dict, model: type[V], error_name=None) -> V:
    @json_safe(f'json-{error_name}' if error_name else 'json')
    @cattrs_safe(f'model-{error_name}' if error_name else 'model')
    def wrapper():
        data = _data
        if isinstance(data, (str, bytes)):
            data = json.loads(data)
        return cattrs.structure(data, model)
    return wrapper()