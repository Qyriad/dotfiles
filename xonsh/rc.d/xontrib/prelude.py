from contextlib import suppress
from typing import cast

from xonsh.aliases import Aliases
from xonsh.built_ins import DynamicAccessProxy, XonshSession

def _load_xontrib_(xsh: XonshSession, **_) -> dict:
    prelude = dict()
    aliases = cast(Aliases, xsh.aliases)

    with suppress(ModuleNotFoundError):
        # Not available on Windows.
        import fcntl
        prelude |= dict(fcntl=fcntl)

    with suppress(ModuleNotFoundError):
        import psutil
        prelude |= dict(
            psutil=psutil,
            Process=psutil.Process
        )

    with suppress(ModuleNotFoundError):
        from unidecode import unidecode
        prelude |= dict(
            unidecode=unidecode,
        )

    with suppress(ModuleNotFoundError):
        import pipe
        prelude |= dict(
            pipe=pipe,
            Pipe=pipe.Pipe,
            select=pipe.select,
            where=pipe.where,
            skip=pipe.skip,
            take=pipe.take,
        )

    with suppress(ModuleNotFoundError):
        import requests
        prelude |= dict(
            requests=requests,
        )

    import importlib
    prelude |= dict(
        importlib=importlib,
    )

    from xonsh.xoreutils.ulimit import ulimit as _ulimit
    aliases['ulimit'] = _ulimit

    import dataclasses
    from dataclasses import dataclass, field
    prelude |= dict(
        dataclasses=dataclasses,
        dataclass=dataclass,
    )


    return prelude
