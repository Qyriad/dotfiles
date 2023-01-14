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

  xonshPkg = pkgs.xonsh.overrideAttrs (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [
      pip
      xonshDirenvPkg
    ];

  });

in

  xonshPkg
