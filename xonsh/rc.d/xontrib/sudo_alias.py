from xonsh.built_ins import XonshSession

def _load_xontrib_(xsh: XonshSession, **_):
    @xsh.aliases.register
    @xsh.aliases.return_command
    def _sudo(args: list) -> list:
        try:
            return ['sudo', *xsh.aliases.eval_alias(args)]
        except ValueError:
            return ['sudo', *args]

    @xsh.aliases.register
    @xsh.aliases.return_command
    def _cappy(args: list) -> list:
        try:
            caps = args[0]
            return ['cappy', caps, *xsh.aliases.eval_alias(args[1:])]
        except (ValueError, IndexError):
            return ['cappy', *args]
