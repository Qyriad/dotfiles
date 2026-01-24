from contextlib import suppress

from xonsh.built_ins import DynamicAccessProxy, XonshSession

def _load_xontrib_(xsh: XonshSession, **_) -> dict:
    prelude = dict()

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


    return prelude
