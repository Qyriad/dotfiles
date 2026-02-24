from collections.abc import Sequence
import inspect
from typing import Any, Callable

from xonsh.built_ins import XonshSession
from xonsh.completers.bash import complete_from_bash
from xonsh.completers.completer import add_one_completer
from xonsh.completers.tools import CompletionContext, CommandContext, CompleterResult
from xonsh.completers.tools import contextual_command_completer_for

def _load_xontrib_(xsh: XonshSession, **_) -> dict[Any, Any]:

    @contextual_command_completer_for("niz")
    def _niz_completer(command: CommandContext) -> CompleterResult:
        first = command.args[0]
        rest = command.args[1:]
        new_command = command._replace(
            args=(
                first._replace(value="nix"),
                *rest,
            )
        )
        return complete_from_bash(CompletionContext(command=new_command))

    # "start" seems to be load-bearing. idk why.
    if "niz" in xsh.completers:
        del xsh.completers["niz"]

    add_one_completer("niz", _niz_completer, loc="start")

    return dict(
        _niz_completer=_niz_completer,
    )
