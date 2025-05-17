from __future__ import annotations

from typing import Dict

from utils import *
from cattrsconfigbase import CattrsConfigBase
from repository import Repository

from pyotherside_utils import *

class RepositoriesManager(CattrsConfigBase):
    _name = 'repos'
    _default_factory = dict
    _data: dict[str, Repository]
    _model = Dict[str, Repository]

    @property
    def repos(self):
        return self._data
    
    def add_repo(self, url: str, repo: Repository):
        self.repos[url] = repo
        self.save()
    
    def remove_repo(self, url: str):
        if url in self.repos:
            self.repos.pop(url)
            self.save()
            return url