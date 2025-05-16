from __future__ import annotations

from pyotherside import send as qsend

from typing import Any, Callable, TypeVar
import urllib.parse
from datetime import datetime
import json
import functools
import traceback as tb
from enum import Enum

from attr import define
import cattrs

T = TypeVar("T", str, Callable)

def convert_proxy(proxy):
    if not proxy:
        return

    p = urllib.parse.urlparse(proxy, 'http') # https://stackoverflow.com/a/21659195
    netloc = p.netloc or p.path
    path = p.path if p.netloc else ''
    p = urllib.parse.ParseResult('http', netloc, path, *p[3:])

    return p.geturl()

def qml_date(date: datetime):
    """Convert to UTC Unix timestamp using milliseconds"""
    return date.timestamp()*1000

class DataFromException(Enum):
    exception_name = 0
    str_exception = 1
    traceback = 2

    def to_data(self, e):
        if self == DataFromException.exception_name:
            return type(e).__name__
        if self == DataFromException.str_exception:
            return str(e)
        if self == DataFromException.traceback:
            return tb.format_exc()
        return ''

def ensure_data_from_exc(data: T | DataFromException, e: Exception) -> T | str:
    return data.to_data(e) if isinstance(data, DataFromException) else data

def show_error(name, info = ''):
    qsend('error', name, str(info))

@define
class ExceptionHandlingInfo:
    name: str
    info: DataFromException | str | Callable[[Exception], str] = ''
    prepend_info: str = ''
    return_on_exc: DataFromException | Any = None

    def show(self, e):
        info = ensure_data_from_exc(self.info, e)
        if callable(info):
            info = info(e)
        show_error(self.name, self.prepend_info + info)

# def exception_safe(exc: type[Exception] | tuple[type[Exception]], name = None, other: DataFromException | Any = None, return_on_exc: DataFromException | Any = None):
def exception_safe(exceptions: dict[type[Exception], ExceptionHandlingInfo | str]):
    def wrapper(f):
        @functools.wraps(f)
        def new_f(*args, **kwargs):
            try:
                return f(*args, **kwargs)
            except tuple(exceptions.keys()) as e:
                exception = next((x for x in exceptions.keys() if isinstance(e, x)), None)
                if exception is not None:
                    handler = exceptions[exception]
                    if isinstance(handler, ExceptionHandlingInfo):
                        handler.show(e)
                        return handler.return_on_exc
                    else:
                        show_error(handler)
                else:
                    # Should never happen, since the dict always has the raised exception type in its keys
                    show_error('unknown', tb.format_exc())

        return new_f
    return wrapper

json_safe = lambda name='json': exception_safe({json.JSONDecodeError: ExceptionHandlingInfo(name, DataFromException.str_exception)})
cattrs_safe = lambda name='model': exception_safe({cattrs.ClassValidationError: ExceptionHandlingInfo(name, lambda e: ', '.join(cattrs.transform_error(e)))})

def load_model(_data: str | dict, model: type[T], error_name=None) -> T:
    @json_safe(f'json-{error_name}' if error_name else 'json')
    @cattrs_safe(f'model-{error_name}' if error_name else 'model')
    def wrapper():
        data = _data
        if isinstance(data, str):
            data = json.loads(data)
        return cattrs.structure(data, model)
    return wrapper()