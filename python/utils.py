from __future__ import annotations

from pyotherside import send as qsend

import json

from pyotherside_utils import *
import cattrs

cattrs_safe = lambda name='model': exception_safe({cattrs.ClassValidationError: ExceptionHandlingInfo(name, lambda e: ', '.join(cattrs.transform_error(e)))})

def load_model(_data: str | dict, model: type[T], error_name=None) -> T:
    @json_safe(f'json-{error_name}' if error_name else 'json')
    @cattrs_safe(f'model-{error_name}' if error_name else 'model')
    def wrapper():
        data = _data
        if isinstance(data, (str, bytes)):
            data = json.loads(data)
        return cattrs.structure(data, model)
    return wrapper()