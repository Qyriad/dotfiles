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

    propagatedBuildInputs = [
      pkgs.direnv
    ];
  };

  xontribAbbrevsPkg = buildPythonPackage rec {
    pname = "xontrib-abbrevs";
    version = "0.0.1";
    format = "pyproject";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-b356G1+DpjqDFR+4WsM2qMu91JaHOnOW4ap3KTth7BY=";
    };
    buildInputs = with pkgs.python3Packages; [
      setuptools
      wheel
      poetry-core
    ];
  };

  xonshExtras = with pkgs.python3Packages; [
    pip
    ipython
    psutil
    unidecode
    xonshDirenvPkg
    xontribAbbrevsPkg
    # Lets xonsh set its process title to "xonsh" instead of "python3.10", which is much less annoying
    # in my tmux window names.
    setproctitle
  ];

  xonshPkg = pkgs.xonsh.overridePythonAttrs (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ xonshExtras;
  });

in

  xonshPkg
