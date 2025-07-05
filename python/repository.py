from __future__ import annotations

from typing import Optional, List

from pyotherside_utils import *
from attrs import define, field
import cattrs
from cattrs.gen import make_dict_unstructure_fn, make_dict_structure_fn, override
import httpx

from utility import Utility
from utils import *
import caching

@define
class Repository:
    # we can't use __future__.annotations in typing here

    # from json
    name: str = ''
    utilities: List[Utility] = field(factory=list)
    banner: str = ''
    icon: str = ''
    rounded_icon: bool = False
    description: str = ''

    # internal
    url: Optional[str] = None

    def utility_from_hash(self, hashed_data):
        "Surprisingly, it is not that slow, and it looks like caching all of this in a dict additionally would take more memory and startup time than time for this function"
        return next((u for u in self.utilities if u.hash == hashed_data), None)

    @property
    def hashed_url(self):
        return sha256(self.url) if self.url is not None else ''

    @classmethod
    def from_json(cls, data, url: str | None = None):
        model = load_model(data, cls, 'repository')
        model.url = url
        return model

    @classmethod
    def from_url(cls, url: str, client: httpx.Client):
        data = client.get(url).content
        return cls.from_json(data, url)

_repo_unstructure_hook = make_dict_unstructure_fn(Repository, cattrs.global_converter, utilities=override(omit=True))
cattrs.global_converter.register_unstructure_hook(Repository, lambda model: {'hash': model.hashed_url, **_repo_unstructure_hook(model), 'icon': caching.cacher.easy(model.icon, update='repoIcon', extra_update=model.hashed_url)})

cattrs.global_converter.register_structure_hook(Repository, make_dict_structure_fn(Repository, cattrs.global_converter, url=override(omit=True)))