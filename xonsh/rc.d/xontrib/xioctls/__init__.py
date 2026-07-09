from xonsh.built_ins import XonshSession

def _load_xontrib_(xsh: XonshSession, **_) -> dict:
    from . import ioctls
    from .ioctls import v4l2
    prelude = dict()
    prelude.update(dict(
        ioctls=ioctls,
        v4l2=v4l2,
    ))
    prelude.update(vars(ioctls))

    return prelude
