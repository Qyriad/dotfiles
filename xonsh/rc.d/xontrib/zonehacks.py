from datetime import datetime
import zoneinfo
from zoneinfo import ZoneInfo

from xonsh.built_ins import DynamicAccessProxy, XonshSession

class Nicely:
    """
    This is a terrible yet amazing hack we've come up with to make printing
    certain kinds of values in convenient formatting easier to read.

    Ex: >>> datetime.now() + timedelta(days=90) >> nicely
    'Sunday, December 12 2022 (12/04/22 5:08:29 PM)'

    Truly, we have become C++.
    """

    def _datetime(self, dt: datetime) -> str:
        return dt.strftime("%A, %B %d %Y (%m/%d/%Y %-I:%M:%S %p) %Z (UTC%z)")

    def __rrshift__(self, other) -> str:
        if isinstance(other, datetime):
            return self._datetime(other)
        else:
            raise TypeError()

class ToZone:
    """ An even worse hack. """

    def __init__(self, zone):
        if isinstance(zone, ZoneInfo):
            self.zone = zone
        elif isinstance(zone, str):
            try:
                self.zone = ZoneInfo(zone)
            except zoneinfo._common.ZoneInfoNotFoundError:
                for name in zoneinfo.available_timezones():
                    if name.split('/')[-1].lower() == zone.lower():
                        self.zone = ZoneInfo(name)
                        break
                else:
                    raise
        else:
            raise TypeError()

    def __getattr__(self, attr):
        return getattr(self.zone, attr)

    def __rrshift__(self, other):
        if isinstance(other, datetime):
            return other.astimezone(tz=self.zone)
        else:
            raise TypeError()

def _load_xontrib_(xsh: XonshSession, **_) -> dict:
    return dict(
        nicely=Nicely(),
        zone=ToZone,
    )
