{
  pkgs,
  lib,
  xonsh-source,
  python-pipe,
  xontrib-abbrevs,
  xonsh-direnv,
  # Setting `programs.xonsh.package` to this causes NixOS to call
  # `.override { extraPackages = }` on us.
  extraPackages ? lib.const [ ],
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
    py.jeepney
    py.pygobject3
    py.jeepney
    py.ds-store
    py.xmltodict
    py.python-box
    py.matplotlib
    py.pillow
    py.pytesseract
    py.beautifulsoup4
    pkgs.gobject-introspection
    pkgs.gtk3
    pkgs.glib
    xonsh-direnv
    xontrib-abbrevs
    python-pipe
  ] ++ (extraPackages py));
in xonshEnv
