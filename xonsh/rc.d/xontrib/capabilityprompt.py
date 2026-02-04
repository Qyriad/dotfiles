import os

from xonsh.built_ins import XonshSession

def _load_xontrib_(xsh: XonshSession, **_) -> None:
    if os.access("/", mode=os.W_OK, effective_ids=True):
        xsh.env['PROMPT_FIELDS']['prompt_end'] = '#' # type: ignore
