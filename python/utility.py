from __future__ import annotations

from enum import Enum, unique
import subprocess
from typing import Any, Optional
from base64 import b64decode

import caching
import utils
from utils import *

from pyotherside_utils import *
from attrs import define
import cattrs
from cattrs.gen import make_dict_structure_fn, override

IMPORT_PATHS: set[str] = set()
STUB_FULL_QML_DATA = {'type': -1, 'content': '', 'aboutType': -1, 'about': ''}

@unique
class DataType(Enum):
    BASE64 = 'base64'
    QML = 'qml'
    QML_LINK = 'qmllink'
    ARCHIVE_LINK = 'archive'

    @property
    def qml_type(self):
        return 0 if self in (self.QML, self.BASE64) else 1

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

    # from json
    name: str
    data_type: DataType
    data: str
    icon: str = ''
    rounded_icon: bool = False
    about_page_type: DataType = DataType.QML_LINK
    about_page: Optional[str] = None

    # internal
    detached_process: Optional[subprocess.Popen] = None

    @property
    def hash(self):
        return sha256(self.data)

    #@cached_property
    @property
    def qml_data(self) -> dict[str, Any]:
        data = {'aboutType': -1, 'about': ''}
        data['type'], data['content'] = self.data_type.qml_data(self.data)

        if self.about_page:
            data['aboutType'], data['about'] = self.about_page_type.qml_data(self.about_page, 'archive.qml', disallow_archives="utilityAboutArchiveNotAllowed")
        elif self.data_type == DataType.ARCHIVE_LINK:
            about_page = Path(data['content']).parent / 'about.qml'
            if about_page.exists():
                data['aboutType'], data['about'] = 1, str(about_page)

        return data
    
    def start_detached(self):
        data = self.qml_data
        if data['type'] != 1:
            show_error("utilityDetachInvalidType")
            return

        with utils.temp.open(f'{self.hash}_main.qml', 'w') as f:
            f.write('''\
import QtQuick 2.0
import Sailfish.Silica 1.0
ApplicationWindow{id:window
allowedOrientations:defaultAllowedOrientations
''')
            main_path = json.dumps(self.qml_data["content"])
            f.write(f'initialPage:{main_path}')
            # TODO: cover
            f.write('}')
            name = str(f.name)

        import_paths = utils.DEFAULT_IMPORT_PATHS | set(IMPORT_PATHS or ())
        import_flags = sum([['-I', x] for x in import_paths], [])
        self.detached_process = subprocess.Popen(['qmlscene', *import_flags, name])

        # qsend("started")
        return self.detached_process

    # These are unused for now:
    @property
    def detached_running(self):
        return self.detached_process and self.detached_process.poll() is None

    def kill_detached(self):
        if self.detached_process:
            self.detached_process.kill()
            process =  self.detached_process
            self.detached_process = None
            return process

@define
class UtilityUnstructureInfo:
    utility: Utility
    full: bool = True
    update_hash: str = ''

def _utility_unstructure(utility: Utility | UtilityUnstructureInfo) -> dict[str, Any]:
    if isinstance(utility, UtilityUnstructureInfo):
        full = utility.full
        update_hash = utility.update_hash
        utility = utility.utility
    else:
        full = True
        update_hash = ''
    data = {
        'name': utility.name,
        'hash': utility.hash,
        'rounded_icon': utility.rounded_icon,

        'loaded': full,
    }
    data.update(utility.qml_data if full else STUB_FULL_QML_DATA)
    data['icon'] = caching.cacher.easy(utility.icon, force_cache=full, update=f'utilityIcon{update_hash}', extra_update=utility.hash)
    return data

_utility_structure_base = make_dict_structure_fn(Utility, cattrs.global_converter,
    detached_process=override(omit=True),
    repository=override(omit=True),
)

cattrs.global_converter.register_unstructure_hook(Utility, _utility_unstructure)
cattrs.global_converter.register_unstructure_hook(UtilityUnstructureInfo, _utility_unstructure)