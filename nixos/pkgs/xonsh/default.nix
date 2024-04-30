{
  pkgs,
  lib,
  python-pipe,
  xontrib-abbrevs,
  xonsh-direnv,
  ...
 }:

let
  inherit (pkgs.python3Packages) setuptools;
  inherit (builtins) attrValues;

  xonsh = pkgs.xonsh.override {
    extraPackages = p: lib.attrValues {
      inherit (p)
        unidecode
        setproctitle
        psutil
        requests
      ;
      inherit
        xonsh-direnv
        xontrib-abbrevs
        python-pipe
      ;
    };
  };

in
  xonsh
