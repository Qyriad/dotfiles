{
  pkgs,
  lib,
  python-pipe,
  xontrib-abbrevs,
  xonsh-direnv,
  ...
 }:

let
  mkXonsh = {
    xonsh,
    python-pipe,
    xonsh-direnv,
    xontrib-abbrevs,
  }: xonsh.override {
    extraPackages = p: with p; [
      unidecode
      setproctitle
      psutil
      requests
      xonsh-direnv
      xontrib-abbrevs
      python-pipe
    ];
  };

  xonsh = pkgs.python3Packages.callPackage mkXonsh {
    inherit (pkgs) xonsh;
    inherit xonsh-direnv xontrib-abbrevs python-pipe;
  };

in
  xonsh
