import io
import shutil
import typing
from typing import cast

from xonsh.aliases import Aliases
from xonsh.built_ins import XonshSession

commands = [
    'df',
    'free',
    'ip',
    'mount',
    'netstat',
    'ping',
    'as',
    'last',
    'lsusb',
    'netstat',
    'ifconfig',
]

aliases_colorized = { }
aliases_colorized['lspci'] = 'lspci'
aliases_colorized['lsdsk'] = 'lsblk -o NAME,FSTYPE,LABEL,TYPE,MOUNTPOINT,SIZE'

grcc = 'grc --colour=on'

def _load_xontrib_(xsh: XonshSession, **_) -> dict:
    aliases = cast(Aliases, xsh.aliases)

    if not shutil.which('grc'):
        aliases.update(aliases_colorized)
        return dict()

    aliases['grcc'] = grcc

    for command in commands:
        aliases[command] = 'grc ' + command
        forced = command + 'c' # Force color, even when piping.
        aliases[forced] = f"{grcc} {command}"

    for command, alias in aliases_colorized.items():
        aliases[command] = f'grc {alias}'
        forced = command + 'c' # Force color, even when piping.
        aliases[forced] = f"{grcc} {alias}"


    # Like per-line, but for the entire stdin text at once.
    @aliases.register
    def _intext(args: list, stdin: io.TextIOWrapper):
        callback: typing.Callable[[str], str] = args[0]
        output = callback(stdin.read())
        print(output)
        return output

    # Append a trailing newline, since some commands don't.
    @aliases.register
    def _withnl(args: list, stdin: io.TextIOWrapper):
        return _intext([print], stdin)

    @aliases.register("pl")
    def _per_line(args: list, stdin: io.TextIOWrapper):
        """
            Callable alias that you can pass a lambda to to process stdin line-by-line. e.g.:
            @ cat ./foo.txt | pl @(lambda line: line.split()[2])
            to get the second whitespace-delimited word of each line.
        """
        callback: typing.Callable[[str], str] = args[0]
        output = "\n".join([str(callback(line)) for line in stdin])
        return output

    return dict()
