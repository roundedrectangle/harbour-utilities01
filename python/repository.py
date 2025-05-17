from __future__ import annotations

from hashlib import sha256

from attrs import define

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