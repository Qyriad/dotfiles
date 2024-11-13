{
  pkgs,
  lib,
  xonsh-source,
  python-pipe,
  xontrib-abbrevs,
  xonsh-direnv,
}:

let

  xonshEnv = pkgs.xonsh.override {
    extraPackages = py: [
      py.unidecode
      py.psutil
      py.requests
      py.pygments
      py.jsondiff
      py.setproctitle
      py.httpx
      py.tqdm
      py.pip
      py.pydbus
      py.pygobject3
      py.jeepney
      pkgs.gobject-introspection
      pkgs.gtk3
      pkgs.glib
      xonsh-direnv
      xontrib-abbrevs
      python-pipe
    ];

    #xonsh = pkgs.xonsh.overridePythonAttrs { dontWrapPythonPrograms = true; };
  };

in xonshEnv
