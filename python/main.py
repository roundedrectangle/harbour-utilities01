from __future__ import annotations

import httpx

from utils import *

client = httpx.Client()

disconnect = lambda: client.close() # So if client is changed, function would still work

def set_proxy(proxy):
    global client
    if client:
        client.close()
    client = httpx.Client(proxy=convert_proxy(proxy))

def set_constants(*args):
    pass