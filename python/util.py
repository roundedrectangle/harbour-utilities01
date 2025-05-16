from __future__ import annotations

import urllib.parse
from datetime import datetime
from pyotherside import send as qsend

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