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

    def qml_data(self, data, archive_file='main.qml', disallow_archives: str | None = None) -> tuple[int, str]:
        if self == DataType.QML:
            return 0, data
        if self == DataType.QML_LINK:
            return 1, str(caching.cacher.cache(data, return_path=True))
        if self == DataType.ARCHIVE_LINK:
            if disallow_archives:
                show_error(disallow_archives)
                return -1, ''
            # path = caching.cacher.get_cached_path(self.data)
            # if not caching.cacher.unpacking_required(path):
            #     return 1, str(caching.cacher.get_unpacked_path(path) / archive_file)
            path: Path = caching.cacher.cache(data, return_path=True) # pyright:ignore[reportAssignmentType]
            return 1, str(caching.cacher.unpack(path) / archive_file)
        if self == DataType.BASE64:
            return 0, b64decode(data).decode()
        return -1, ''

@define
class Utility:
    # we can't use __future__.annotations in typing here
    name: str
    data_type: DataType
    data: str
    about_page_type: DataType = DataType.QML_LINK
    about_page: Optional[str] = None

    @property
    def qml_data(self) -> dict[str, Any]:
        data = {'hash': '', 'aboutType': -1, 'about': ''}
        data['type'], data['content'] = self.data_type.qml_data(self.data)

        if self.about_page:
            data['aboutType'], data['about'] = self.about_page_type.qml_data(self.about_page, disallow_archives="utilityAboutArchiveNotAllowed")
        elif self.data_type == DataType.ARCHIVE_LINK:
            about_page = Path(data['content']).parent / 'about.qml'
            if about_page.exists():
                data['aboutType'], data['about'] = 1, str(about_page)
        if data['type'] == 1:
            data['hash'] = sha256(data['content'])

        return data

_base_utility_unstructure = make_dict_unstructure_fn(Utility, cattrs.global_converter,
    data_type=override(omit=True),
    data=override(omit=True),
)
def utility_unstructure(utility: Utility) -> dict[str, Any]:
    data = _base_utility_unstructure(utility)
    data.update(utility.qml_data)
    return data

cattrs.global_converter.register_unstructure_hook(Utility, utility_unstructure)