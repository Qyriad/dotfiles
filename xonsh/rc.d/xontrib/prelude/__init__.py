from contextlib import suppress
import importlib
from typing import cast, Callable, Any

from xonsh.aliases import Aliases
from xonsh.built_ins import DynamicAccessProxy, XonshSession

def _load_xontrib_(xsh: XonshSession, **_) -> dict:
    from collections.abc import Iterable
    import importlib

    # Make sure our submodules are also reloaded when we get reloaded.
    from . import iterators
    importlib.reload(iterators)

    prelude = dict()
    aliases = cast(Aliases, xsh.aliases)

    import builtins, operator, types, typing, collections, collections.abc
    import functools, itertools, contextlib, dataclasses
    import os, sys, io, errno, ctypes
    import struct, re, shlex, shutil, textwrap
    import pathlib
    import json, tomllib

    prelude |= dict(
        builtins=builtins,
        operator=operator,
        types=types,
        typing=typing,
        collections=collections,
        functools=functools,
        itertools=itertools,
        contextlib=contextlib,
        dataclasses=dataclasses,
        dataclass=dataclasses.dataclass,
        field=dataclasses.field,
        os=os,
        sys=sys,
        io=io,
        errno=errno,
        ctypes=ctypes,
        struct=struct,
        re=re,
        shlex=shlex,
        shutil=shutil,
        textwrap=textwrap,
        pathlib=pathlib,
        Path=pathlib.Path,
        json=json,
        tomllib=tomllib,
    )

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
        tolist = pipe.Pipe(list)
        prelude |= dict(
            pipe=pipe,
            Pipe=pipe.Pipe,
            select=pipe.select,
            where=pipe.where,
            skip=pipe.skip,
            take=pipe.take,
            tolist=tolist,
        )

    with suppress(ModuleNotFoundError):
        import requests
        prelude |= dict(
            requests=requests,
        )

    import collections.abc
    prelude |= dict(
        collections=collections,
    )

    import importlib
    prelude |= dict(
        importlib=importlib,
    )

    import itertools
    prelude |= dict(
        itertools=itertools,
    )

    from xonsh.xoreutils.ulimit import ulimit as _ulimit
    aliases['ulimit'] = _ulimit

    import dataclasses
    from dataclasses import dataclass, field
    prelude |= dict(
        dataclasses=dataclasses,
        dataclass=dataclass,
    )

    import tomllib
    prelude |= dict(
        tomllib=tomllib,
    )

    prelude |= dict(
        splat=iterators.splat,
        iter_once=iterators.iter_once,
        ignore=iterators.ignore,
        ignore_each=iterators.ignore_each,
    )


    return prelude
