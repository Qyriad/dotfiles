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
      xonsh-direnv
      xontrib-abbrevs
      python-pipe
    ];

    #xonsh = pkgs.xonsh.overridePythonAttrs { dontWrapPythonPrograms = true; };
  };

in xonshEnv
