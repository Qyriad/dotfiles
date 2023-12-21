{ pkgs, xonsh-direnv-src, xontrib-abbrevs-src, fetchPypi, ... }:

let
  inherit (builtins) path attrValues;
  inherit (pkgs.python3Packages) buildPythonPackage;

  xonsh-direnv = buildPythonPackage {
    pname = "xonsh-direnv";
    version = "1.6.1";

    buildInputs = attrValues {
      inherit (pkgs) direnv;
    };

    src = path {
      path = xonsh-direnv-src;
      name = "xonsh-direnv-src";
    };
  };

  xontrib-abbrevs = buildPythonPackage {
    pname = "xontrib-abbrevs";
    version = "0.0.1";

    format = "pyproject";

    buildInputs = attrValues {
      inherit (pkgs.python3Packages)
        setuptools
        wheel
        poetry-core
      ;
    };

    src = path {
      path = xontrib-abbrevs-src;
      name = "xontrib-abbrevs-src";
    };
  };

  pipe =
    let
      pname = "pipe";
      name = pname;
      version = "2.0";
    in
      buildPythonPackage {

        inherit pname version;

        src = fetchPypi {
          inherit pname version;
          sha256 = "sha256-oc8/KfmFdrfmVSIxFCvHEejdMkUTosRSX8aMM/R/q60=";
        };

        format = "pyproject";

        nativeBuildInputs = attrValues {
          inherit (pkgs.python3Packages)
            setuptools
            wheel
          ;
        };

      } # buildPythonPackage
  ; # pipe

  xonsh = pkgs.xonsh.overridePythonAttrs (old: {
    propagatedBuildInputs = attrValues {
      inherit (pkgs.python3Packages)
        pip
        ipython
        unidecode
        # Lets xonsh set its process title to "xonsh" instead of "python3.10", which is much less annoying
        # in my tmux window names.
        setproctitle
        psutil
      ;
      inherit
        xonsh-direnv
        xontrib-abbrevs
        pipe
      ;
    } ++ old.propagatedBuildInputs;

    buildInputs = attrValues {
      inherit (pkgs.python3Packages)
        setuptools
      ;
    };
  });
in {
  inherit xonsh xontrib-abbrevs xonsh-direnv;
}
