from __future__ import annotations

from attrs import define
import httpx

from utility import Utility
from utils import *

@define
class Repository:
    name: str = ''
    utilities: list[Utility] = []
    description: str = ''

    @classmethod
    def from_json(cls, data):
        return load_model(data, cls, 'repository')
    
    @classmethod
    def from_url(cls, url, client: httpx.Client):
        data = client.get(url).content
        return cls.from_json(data)