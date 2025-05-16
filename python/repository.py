from __future__ import annotations

from hashlib import sha256

from attrs import define

from utility import Utility

@define
class Repository:
    name: str
    utilities: list[Utility] = []
    description: str | None = None