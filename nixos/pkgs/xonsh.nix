{ pkgs }:

let

  inherit (pkgs.python3Packages) pip fetchPypi buildPythonPackage;

  xonshDirenvPkg = buildPythonPackage rec {
    pname = "xonsh-direnv";
    version = "1.6.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "Nt8Da1EtMVWZ9mbBDjys7HDutLYifwoQ1HVmI5CN2Ww=";
    };
  };

  xonshExtras = with python3Packages; [
    ipython
    psutil
    unidecode
    xonshDirenvPkg
    # Lets xonsh set its process title to "xonsh" instead of "python3.10", which is much less annoying
    # in my tmux window names.
    setproctitle
  ];

  xonshPkg = pkgs.xonsh.overridePythonAttrs (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ xonshExtras;
  });

in

  xonshPkg
