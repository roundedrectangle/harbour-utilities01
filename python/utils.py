from __future__ import annotations
from enum import Enum

from pyotherside import send as qsend

from typing import TypeVar
import urllib.parse
from datetime import datetime
import json
import functools
import traceback as tb

import cattrs

T = TypeVar("T")

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

class ReturnOnException(Enum):
    custom = 0
    exception = 1
    traceback = 2

def show_error(name, info = '', other = None):
    qsend('error', name, str(info), other)

def exception_safe(exc: type[Exception] | tuple[type[Exception]], return_on_exception: ReturnOnException = ReturnOnException.custom, custom_return=None):
    def wrapper(f):
        @functools.wraps(f)
        def new_f(*args, **kwargs):
            try:
                return f(*args, **kwargs)
            except exc as e:
                info = tb.format_exc()
                show_error(info)
                if return_on_exception == ReturnOnException.custom:
                    return custom_return
                if return_on_exception == ReturnOnException.exception:
                    return e
                return info
        return new_f
    return wrapper

@exception_safe(json.JSONDecodeError)
def load_model(data: str | dict, model: type[T]) -> T:
    if isinstance(data, str):
        data = json.loads(data)
    return cattrs.structure(data, model)