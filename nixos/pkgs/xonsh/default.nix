{
  pkgs,
  lib,
  python-pipe,
  xontrib-abbrevs,
  xonsh-direnv,
  ...
 }:

let
  xonshPath = pkgs.path + "/pkgs/by-name/xo/xonsh/unwrapped.nix";
  xonsh-unwrapped = pkgs.callPackage xonshPath { };
  pythonEnv = pkgs.python3.withPackages (ps: [
    (ps.toPythonModule xonsh-unwrapped)
    xonsh-direnv
    xontrib-abbrevs
    python-pipe
  ] ++ (with ps; [
    unidecode
    setproctitle
    psutil
    requests
    pygments
  ]));

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
      pygments
    ];
  };

  xonsh = pkgs.python3Packages.callPackage mkXonsh {
    inherit (pkgs) xonsh;
    inherit xonsh-direnv xontrib-abbrevs python-pipe;
  };

in
  #xonsh
  pythonEnv // { inherit (xonsh-unwrapped) pname version meta passthru; }
