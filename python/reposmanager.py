from __future__ import annotations

from typing import Dict, List, Set

from utils import *
from cattrsconfigbase import CattrsConfigBase
from repository import Repository

from pyotherside_utils import *

class RepositoriesManager(CattrsConfigBase):
    _name = 'repos'
    _default_factory = set
    _data: set[str]
    _model = Set[str]
    _unstructure_as = List[str] # JSON does not support sets

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