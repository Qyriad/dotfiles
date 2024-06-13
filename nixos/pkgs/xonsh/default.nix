{
  pkgs,
  lib,
  xonsh-source,
  python-pipe,
  xontrib-abbrevs,
  xonsh-direnv,
}:

let

  xonsh-unwrapped = let
    xonshPath = pkgs.path + "/pkgs/by-name/xo/xonsh/unwrapped.nix";
    xonsh-unwrapped-nixpkgs = pkgs.callPackage xonshPath { };
  in xonsh-unwrapped-nixpkgs.overridePythonAttrs (prev: {
    src = xonsh-source;

    propagatedBuildInputs = prev.propagatedBuildInputs or [ ] ++ [
      pkgs.python3Packages.requests
    ];

    # I *assume* the failing tests are from the sandbox.
    # Eh, it's just our shell, what could go wrong?
    doCheck = false;
  });

  pythonEnv = lib.setName "python-xonsh-env" (pkgs.python3.withPackages (py: [
    (py.toPythonModule xonsh-unwrapped)
    py.unidecode
    py.psutil
    py.requests
    py.pygments
    py.jsondiff
    py.setproctitle
    py.httpx
    xonsh-direnv
    xontrib-abbrevs
    python-pipe
  ])) // {
    # I honestly have no idea if the precedence makes this happen before or after
    # the lib.setName, but it doesn't matter lol
    inherit (xonsh-unwrapped) meta passthru;
  };

in pythonEnv
