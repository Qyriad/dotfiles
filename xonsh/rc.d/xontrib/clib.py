from typing import TYPE_CHECKING

from xonsh.built_ins import XonshSession

if TYPE_CHECKING:
    from ctypes import CDLL
    global cached_libraries
    cached_libraries: dict[str, CDLL] = dict()

cached_libraries = dict()

def _load_xontrib_(xsh: XonshSession, **_) -> dict:
    from ctypes import CDLL, cdll, c_char_p, byref, c_uint
    from _ctypes import CFuncPtr
    from pathlib import Path
    import os
    import shutil
    import subprocess

    prelude = dict()

    def prepend_os_path(var_name: str, elem: str):
        old = os.getenv(var_name, '').split(os.pathsep)
        os.environ[var_name] = os.pathsep.join([elem, *old])

    def find_clib(name: str, exe_hint: Path | str | None = None) -> CDLL:
        if cached := cached_libraries.get(name):
            return cached

        match exe_hint:
            case str(cmd):
                if found := shutil.which(cmd):
                    exe_hint = Path(found)
                else:
                    raise FileNotFoundError(cmd)

                exe_hint = exe_hint.resolve()
                lib_path = exe_hint.parent.parent.joinpath('lib').as_posix()
                prepend_os_path('LD_LIBRARY_PATH', lib_path)
                prepend_os_path('LIBRARY_PATH', lib_path)

        sofile = subprocess.check_output(['find-libs', name], encoding='utf-8').strip()
        if not sofile:
            raise FileNotFoundError(f'lib{name}.so')

        library = cdll.LoadLibrary(sofile)
        cached_libraries[name] = library
        return library

    def _c_errcheck(result, func: CFuncPtr, args):
        assert isinstance(result, int)
        if err_code := abs(result):
            raise OSError(err_code, os.strerror(err_code))

        byref_args = []
        for arg in args:
            if not hasattr(arg, "value") and hasattr(arg, "_obj"):
                byref_args.append(arg._obj)

        if byref_args:
            if len(byref_args) == 1:
                return byref_args.pop()
            return tuple(byref_args)

        return None

    def check_ccall(fn: CFuncPtr, *args):
        fn.errcheck = _c_errcheck # type: ignore
        return fn(*args)

    prelude.update(dict(
        find_clib=find_clib,
        check_ccall=check_ccall,
    ))

    return prelude
