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
  xonsh-unwrapped = (pkgs.callPackage xonshPath { });

  #.overridePythonAttrs (prev: {
  #  src = pkgs.fetchFromGitHub {
  #    owner = "xonsh";
  #    repo = "xonsh";
  #    rev = "c89a7267befa1a32d3732862ce52eac966f4674b"; # Main 2024/06/02
  #    hash = "sha256-w8oQuTdWn/MAC869SmGIO8pEa91kwluWSXgywQP37Oc=";
  #  };
  #
  #  propagatedBuildInputs = prev.propagatedBuildInputs ++ [
  #    pkgs.python3Packages.requests
  #  ];
  #});

  pythonEnv = (pkgs.python3.withPackages (ps: [
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
    jsondiff
  ]))).overrideAttrs {
    name = "python-xonsh-env";
  };

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
  pythonEnv // {
    inherit (xonsh-unwrapped) pname version meta passthru;
  }
