from __future__ import annotations

from typing import TYPE_CHECKING, List, Set

from utils import *
from cattrsconfigbase import CattrsConfigBase
from repository import Repository

from pyotherside_utils import *

if TYPE_CHECKING:
    from caching import Cacher

class RepositoriesManager(CattrsConfigBase):
    _name = 'repos'
    _default_factory = set
    _data: set[str]
    _model = Set[str]
    _unstructure_as = List[str] # JSON does not support sets

    _repos_cache: dict[str, Repository]

    def __init__(self, location, cacher: Cacher):
        super().__init__(location)
        self.cacher = cacher
        self._repos_cache = {}

    @property
    def repos(self):
        return self._data
    
    def add_repo(self, url: str):
        self.repos.add(url)
        self.save()

    def remove_repo(self, url: str):
        if url in self.repos:
            self.repos.remove(url)
            self.save()
            return url
    
    def load_repo(self, url: str, force=False, force2=False):
        hashed = sha256(url)
        if force or hashed not in self._repos_cache:
            self._repos_cache[hashed] = Repository.from_json(self.cacher.cache(url, force=force2), url)
        return self._repos_cache[hashed]
    
    def __iter__(self):
        for r in self.repos:
            yield self.load_repo(r)