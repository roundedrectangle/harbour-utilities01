from __future__ import annotations

from pathlib import Path
from threading import Thread

from pyotherside_utils import *

DEFAULT_USER_AGENT = 'harbour-utilities01'

class Cacher(CacherBase):
    """Caches single files."""
    def __init__(
        self,
        cache: Path | str,
        update_period: timedelta | int | None,
        proxy: str | None = None,
        user_agent: str | None = None,
    ):
        super().__init__(update_period, proxy=proxy, user_agent=user_agent if user_agent is not None else DEFAULT_USER_AGENT)
        self.path = Path(cache) / 'files'

        self._on_download = lambda url, saved: None
    
    def get_cached_path(self, url: str, extension: str | None = None, default_extension: str = 'u01'):
        extension = extension or get_extension_from_url(url, default=default_extension)
        url = sha256(url)
        return self.path / f'{url}.{extension}'
    
    def update_required(self, url: str, extension: str | None = None):
        return super().update_required(self.get_cached_path(url, extension))

    def on_download(self, f):
        if callable(f):
            self._on_download = f
        return f
    
    def cache(self, url: str, extension: str | None = None, force=False):
        """Returns True if download succeeded, and None if not (including when it was not needed)."""
        if self.update_period == None: return # Never set in settings
        if force or self.update_required(url, extension):
            path = self.get_cached_path(url, extension)
            path.parent.mkdir(parents=True, exist_ok=True)
            if self.download_save(url, path):
                self._on_download(url, extension)
                return True
    
    def cache_bg(self, url: str, extension: str | None = None, force=False):
        Thread(target=self.cache, args=(url, extension, force)).start()