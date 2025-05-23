from __future__ import annotations

from typing import Optional

from attrs import define

@define
class Utility:
    # we can't use __future__.annotations in typing here
    name: str
    description: Optional[str] = None
    qml: Optional[str] = None