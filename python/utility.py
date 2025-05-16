from __future__ import annotations

from attrs import define

@define
class Utility:
    name: str
    description: str | None = None