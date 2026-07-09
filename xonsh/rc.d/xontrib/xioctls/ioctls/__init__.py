from collections.abc import Callable
from dataclasses import dataclass
import enum
from enum import Enum, IntEnum
import typing
import types
from typing import dataclass_transform, override, TypeVar, TYPE_CHECKING
from pprint import pprint

_IOC_NRBITS = 8
_IOC_TYPEBITS = 8
_IOC_SIZEBITS = 14
_IOC_DIRBITS = 2

_IOC_NRMASK   = (1 << _IOC_NRBITS) - 1
_IOC_TYPEMASK = (1 << _IOC_TYPEBITS) - 1
_IOC_SIZEMASK = (1 << _IOC_SIZEBITS) - 1
_IOC_DIRMASK  = (1 << _IOC_DIRBITS) - 1

_IOC_NRSHIFT   = 0
_IOC_TYPESHIFT = _IOC_NRSHIFT + _IOC_NRBITS
_IOC_SIZESHIFT = _IOC_TYPESHIFT + _IOC_TYPEBITS
_IOC_DIRSHIFT  = _IOC_SIZESHIFT + _IOC_SIZEBITS


_IOC_NONE = 0
_IOC_WRITE = 1
_IOC_READ = 2

def _IOC(dir: int, type: int | str, nr: int, size: int) -> int:
    if isinstance(type, str):
        assert len(type) == 1
        type = ord(type)
    return (
        ((dir)  << _IOC_DIRSHIFT) |
        ((type) << _IOC_TYPESHIFT) |
        ((nr)   << _IOC_NRSHIFT) |
        ((size) << _IOC_SIZESHIFT)
    )

def _IO(type: int | str, nr: int) -> int:

    return _IOC(_IOC_NONE, type, nr, 0)

def _IOR(type: int | str, nr: int, argtype: int) -> int:
    return _IOC(_IOC_READ, type, nr, argtype)

def _IOW(type: int | str, nr: int, argtype: int) -> int:
    return _IOC(_IOC_WRITE, type, nr, argtype)

def _IOWR(type: int | str, nr: int, argtype: int) -> int:
    return _IOC(_IOC_READ | _IOC_WRITE, type, nr, argtype)

def _common_prefix(strings: list[str]) -> str:
    shortest = min(strings, key=len)
    for idx, ch in enumerate(shortest):
        if any(elem[idx] != ch for elem in strings):
            return shortest[:idx]
    return shortest

#EnumT = TypeVar('EnumT', type[Enum])
def alias_prefix[T: type[Enum]](prefix: str) -> Callable[[T], T]:
    def impl(cls: T) -> T:
        for value in cls:
            value._add_alias_(f'{prefix}{value.name}')

        return cls

    return impl


class IoctlEnum(IntEnum):
    def __repr__(self):
        return f"<{self.prefix()}.{self.name}: 0x{self.value:x}"

    @classmethod
    def prefix(cls) -> str:
        return cls.__name__


if __name__ == '__main__':
    class TermIoctls(IoctlEnum):
        CGWINSZ = 0x5413

        @classmethod
        @override
        def prefix(cls) -> typing.Literal['TIO']:
            return 'TIO'

    typing.reveal_type(TermIoctls.CGWINSZ)


    print(f"{TermIoctls=}")
    #print(f"{dir(TermIoctls)=}")
    pprint(dir(TermIoctls))
    pprint(vars(TermIoctls))
    winsz = TermIoctls.CGWINSZ
    print(f"{winsz=}")

    print(TermIoctls.CGWINSZ)


#from dataclasses import dataclass
#import fcntl
#import struct
#from typing import Annotated, NamedTuple
#
#import termios
#
#class StructWinsize(NamedTuple):
#    ws_row: int
#    ws_col: int
#    ws_xpixel: int
#    ws_ypixel: int
#
##StructWinsize = namedtuple('StructWinsize', 'ws_row ws_col ws_xpixel ws_ypixel')
#
#@dataclass
#class KnownIoctl:
#    request: int
#    arg: type[NamedTuple]
#
#class Tioc:
#    """Terminal IO Control"""
#
#    #GWINSZ: Annotated[int, "TIOZGWINSZ"] = termios.TIOCGWINSZ
#    GWINSZ: KnownIoctl = KnownIoctl(termios.TIOCGWINSZ, StructWinsize)
#
