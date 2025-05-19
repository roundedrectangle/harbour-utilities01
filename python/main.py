from __future__ import annotations

from pathlib import Path

import httpx
from pyotherside_utils import *

from caching import Cacher
from reposmanager import RepositoriesManager
from utils import *

data: Path | None = None
cache: Path | None = None

repos_manager: RepositoriesManager | None = None
cacher: Cacher | None = None

client = httpx.Client()

disconnect = lambda: client.close() # So if client is changed, function would still work

def set_proxy(proxy):
    global client
    if client:
        client.close()
    client = httpx.Client(proxy=convert_proxy(proxy))

def set_constants(_data, _cache, period):
    global data, cache, repos_manager, cacher
    data, cache = Path(_data), Path(_cache)
    repos_manager = RepositoriesManager(data)
    cacher = Cacher(cache, period)

def set_cache_period(period):
    if cacher:
        cacher.update_period = period


def add_repo(url):
    if repos_manager:
        repos_manager.add_repo(url)

def remove_repo(url):
    if repos_manager:
        repos_manager.remove_repo(url)