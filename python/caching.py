from __future__ import annotations

from pathlib import Path
import shutil
from datetime import timedelta
from threading import Thread

from pyotherside_utils import *

TYPE_CHECKING = False
if TYPE_CHECKING:
    import httpx

DEFAULT_USER_AGENT = 'harbour-utilities01'
UPDATE_PERIOD_MAP = (
    timedelta(), # On app restart
    timedelta(hours=1),
    timedelta(1),
    timedelta(weeks=1),
    timedelta(30),
    timedelta(182.5), # half-yearly
    timedelta(365),
)

cacher: Cacher = None # pyright:ignore[reportAssignmentType]

class Cacher(CacherBase):
    """Caches single files and unpacked archives."""
    caching: set[str]

    def __init__(
        self,
        cache: Path | str,
        update_period: timedelta | int,
        proxy: str | None = None,
        user_agent: str | None = None,
        httpx_client: httpx.Client | None = None,
    ):
        super().__init__(update_period, UPDATE_PERIOD_MAP, proxy=proxy, user_agent=user_agent if user_agent is not None else DEFAULT_USER_AGENT, httpx_client=httpx_client)
        self.path = Path(cache)
        self.files_path = self.path / 'files'
        self.unpacked_path = self.path / 'unpacked'

        self.caching = set()

        self._on_download = lambda url, saved: None

    def get_cached_path(self, url: str, extension: str | None = None, default_extension: str = 'u01'):
        extension = extension or get_extension_from_url(url, default=default_extension)
        url = sha256(url)
        return self.files_path / f'{url}.{extension}'

    def update_required(self, url: str, extension: str | None = None):
        return super().update_required(self.get_cached_path(url, extension))

    def on_download(self, f):
        if callable(f):
            self._on_download = f
        return f

    def cache(self, url: str, extension: str | None = None, force=False, return_data=True, return_path=False):
        """Returns data (cached if it is cached already)."""
        path = self.get_cached_path(url, extension)
        if force or self.update_required(url, extension):
            path.parent.mkdir(parents=True, exist_ok=True)
            try:
                data = self.download_save(url, path, return_data and not return_path)
                if data is not None:
                    self._on_download(url, extension)
                    if not return_path:
                        return data
            except:
                if return_data:
                    return None
        if return_path:
            return path
        if return_data:
            with open(path, 'rb') as f:
                return f.read()

    def get_unpacked_path(self, path: str | Path):
        hashed_url = Path(path).name.split('.')[0]
        return self.unpacked_path / hashed_url

    def unpacking_required(self, path: str | Path):
        unpacked = self.get_unpacked_path(path)
        return not unpacked.exists() or not any(unpacked.iterdir()) or super().update_required(unpacked)

    def unpack(self, archive: str | Path, force=False):
        archive = Path(archive)
        unpacked = self.get_unpacked_path(archive)
        if force or self.unpacking_required(archive):
            shutil.rmtree(unpacked, ignore_errors=True)
            unpacked.mkdir(parents=True, exist_ok=True)
            shutil.unpack_archive(archive, unpacked) # FIXME: should we use try/except here?
        return find_extracted_contents(unpacked)
    
    def _cache_bg(self, url: str, update: str, extra=[]):
        hashed = sha256(url)
        if hashed in self.caching:
            return
        self.caching.add(hashed)
        qsend(update, *extra, str(self.cache(url, return_path=True)))
        self.caching.remove(hashed)
    
    def easy(self, url: str, force_cache=False, update='', extra_update=[]):
        if url and (force_cache or not self.update_required(url)):
            return str(self.cache(url, return_path=True))
        if url and update:
            Thread(target=self._cache_bg, args=(url, update, (extra_update,) if extra_update else ())).start()
        return url # recache in thread