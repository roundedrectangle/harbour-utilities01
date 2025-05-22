from __future__ import annotations

from pyotherside_utils import *
from attrs import define
import httpx

from utility import Utility
from utils import *

@define
class Repository:
    url: str | None = None
    hashed_url: str | None = None

    name: str = ''
    utilities: list[Utility] = []
    description: str = ''

    @classmethod
    def from_json(cls, data, url: str | None = None):
        model = load_model(data, cls, 'repository')
        model.url = url
        model.hashed_url = None if url is None else sha256(url)
        return model

    @classmethod
    def from_url(cls, url: str, client: httpx.Client):
        data = client.get(url).content
        return cls.from_json(data, url)
    
    @property
    def qml_data(self):
        return {
            'url': self.url,
            'hash': self.hashed_url,
            'name': self.name,
            'description': self.description,
        }