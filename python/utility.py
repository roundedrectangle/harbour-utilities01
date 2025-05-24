from __future__ import annotations

from enum import Enum, unique
from typing import Any, Optional
from base64 import b64decode

import caching

# FIXME: there is some issue that when we don't import pyotherside_utils, caching.cacher becomes None

from pyotherside_utils import *
from attrs import define
import cattrs
from cattrs.gen import make_dict_unstructure_fn, override

@unique
class DataType(Enum):
    BASE64 = 'base64'
    QML = 'qml'
    QML_LINK = 'qmllink'
    ARCHIVE_LINK = 'archive'

@define
class Utility:
    # we can't use __future__.annotations in typing here
    name: str
    data_type: DataType
    data: str
    description: Optional[str] = None

    @property
    def qml_data(self) -> tuple[int, str]:
        if self.data_type == DataType.QML:
            return 0, self.data
        if self.data_type == DataType.QML_LINK:
            return 1, str(caching.cacher.cache(self.data, return_path=True))
        if self.data_type == DataType.ARCHIVE_LINK:
            # path = caching.cacher.get_cached_path(self.data)
            # if not caching.cacher.unpacking_required(path):
            #     return 1, str(caching.cacher.get_unpacked_path(path) / 'main.qml')
            path: Path = caching.cacher.cache(self.data, return_path=True) # pyright:ignore[reportAssignmentType]
            return 1, str(caching.cacher.unpack(path) / 'main.qml')
        if self.data_type == DataType.BASE64:
            return 0, b64decode(self.data).decode()
        return -1, ''

_base_utility_unstructure = make_dict_unstructure_fn(Utility, cattrs.global_converter,
    data_type=override(omit=True),
    data=override(omit=True),
)
def utility_unstructure(utility: Utility) -> dict[str, Any]:
    res = _base_utility_unstructure(utility)
    res['type'], res['content'] = utility.qml_data
    return res

cattrs.global_converter.register_unstructure_hook(Utility, utility_unstructure)