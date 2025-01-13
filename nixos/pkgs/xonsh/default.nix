{
  pkgs,
  lib,
  xonsh-source,
  python-pipe,
  xontrib-abbrevs,
  xonsh-direnv,
}:

let

  # This seems to be what makes it all work the best, for now.
  xonshEnv = pkgs.python3.withPackages (py: [
    pkgs.xonsh-unwrapped
    py.ply
    py.prompt-toolkit
    py.pygments

    py.unidecode
    py.psutil
    py.requests
    py.jsondiff
    py.setproctitle
    py.httpx
    py.tqdm
    py.pip
    py.pydbus
    py.pygobject3
    py.jeepney
    py.ds-store
    pkgs.gobject-introspection
    pkgs.gtk3
    pkgs.glib
    xonsh-direnv
    xontrib-abbrevs
    python-pipe
  ]);
in xonshEnv
