from collections.abc import Iterable, Iterator
from typing import Any, Callable, Never

def splat[*Ts, R](f: Callable[[*Ts], R]) -> Callable[[tuple[*Ts]], R]:
    """Adapt f(*args) into g(iterable). Like itertools.starmap for a single item."""

    # Technically it should be `Iterable[*Ts]`, because not only tuples are accepted.
    # But tuple type vars are not allowed as type argument to seemingly anything but
    # `tuple` or `Callable`.
    def starred(iterable: tuple[*Ts]) -> R:
        return f(*iterable)

    # For inspect.unwrap.
    starred.__wrapped__ = f

    return starred

from typing import Self

class IterOnce[T](Iterable[T]):
    def __init__(self, item: T):
        self._item = item

    def _done_next(self) -> T:
        raise StopIteration

    def __iter__(self) -> Self:
        return type(self)(self._item)

    def __next__(self) -> T:
        # Replace the next function.
        self.__next__ = self._done_next
        return self._item

class IterNever[T](Iterable[T]):
    def __iter__(self) -> Self:
        return type(self)()

    def __next__(self) -> Never:
        raise StopIteration

def iter_once[T](obj: T) -> Iterable[T]:
    yield obj

def ignore(obj: object) -> None:
    pass

def ignore_each(iterable: Iterable[object]) -> Iterable[None]:
    for _ in iterable:
        pass
    yield



    #return IterOnce(obj)

    #return [obj]
