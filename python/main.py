from __future__ import annotations

from pathlib import Path
from threading import Thread, Event
import shutil

import httpx
from pyotherside_utils import *

from caching import Cacher
import caching
from repository import Repository
from reposmanager import RepositoriesManager
import utils
from utils import *

data: Path | None = None
cache: Path | None = None

HTTPX_CLIENT_ARGS: dict[str, Any] = {'follow_redirects': True}

repos_manager: RepositoriesManager = None # pyright:ignore[reportAssignmentType]
client = httpx.Client(**HTTPX_CLIENT_ARGS)
stop_event = Event()
utilities_stop_event = Event()

def set_proxy(proxy):
    global client
    if client:
        client.close()
    client = httpx.Client(proxy=convert_proxy(proxy), **HTTPX_CLIENT_ARGS)
    if caching.cacher:
        caching.cacher.httpx_client = client
    if utils.temp:
        utils.temp.httpx_client = client

def set_constants(_data, _cache, period):
    global data, cache, repos_manager, client
    data, cache = Path(_data), Path(_cache)

    if client.is_closed:
        client = httpx.Client(**HTTPX_CLIENT_ARGS)
    if stop_event.is_set:
        stop_event.clear()

    caching.cacher = Cacher(cache, period, httpx_client=client)
    repos_manager = RepositoriesManager(data)
    utils.temp = TemporaryManager(_cache)

def set_cache_period(period):
    if caching.cacher:
        caching.cacher.update_period = period

def disconnect():
    client.close()
    stop_event.set()


def send_repo(repo: str | Repository | None, force=False, force2=False):
    if isinstance(repo, Repository):
        qsend('repo', cattrs.unstructure(repo))
    elif isinstance(repo, str):
        Thread(target=lambda: send_repo(repos_manager.load_repo(repo, force, force2))).start()

def _request_repos():
    qsend('reposLoaded', False)
    for repo in repos_manager:
        if stop_event.is_set():
            break
        send_repo(repo)
    qsend('reposLoaded', True)

request_repos = lambda: Thread(target=_request_repos).start()


def add_repo(url):
    repos_manager.add_repo(url)
    send_repo(url)

def remove_repo(url, hashed=None):
    repos_manager.remove_repo(url)
    qsend('repoRemove', hashed or sha256(url))

# TODO: replacing repos (when update is available (incl. forcefully))

def reload_repo(url, hashed=None):
    Thread(target=lambda:
        qsend('repoUpdate', hashed or sha256(url), cattrs.unstructure(repos_manager.load_repo(url, True, True)))
    ).start()

def _send_utilities(hashed_url):
    utilities_stop_event.clear()
    repo = repos_manager.get_cached_repo(hashed_url)
    if not repo:
        show_error('utilitiesRepoCacheNotFound')
        qsend(f'error{hashed_url}')
        return
    for utility in repo.utilities:
        if stop_event.is_set() or utilities_stop_event.is_set():
            break
        qsend(f'utility{hashed_url}', cattrs.unstructure(utility))
    qsend(f"finished{hashed_url}")
    utilities_stop_event.clear()
send_utilities = lambda url: Thread(target=_send_utilities, args=(url,)).start()

stop_utilities = utilities_stop_event.set

def clear_cache():
    if cache:
        shutil.rmtree(cache)

def launch_detached(repo_hash, utility_hash):
    repo = repos_manager.get_cached_repo(repo_hash)
    if not repo:
        qsend('detachError', 1)
        return
    utility = repo.utility_from_hash(utility_hash)
    if not utility:
        qsend('detachError', 2)
        return
    if utility.start_detached():
        qsend('detachSuccess')