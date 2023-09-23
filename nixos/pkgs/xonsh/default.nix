{ pkgs, xonsh-direnv-src, xontrib-abbrevs-src, ... }:

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

  xonsh = pkgs.xonsh.overridePythonAttrs (old: {
    propagatedBuildInputs = attrValues {
      inherit (pkgs.python3Packages)
        pip
        ipython
        unidecode
        # Lets xonsh set its process title to "xonsh" instead of "python3.10", which is much less annoying
        # in my tmux window names.
        setproctitle
      ;
      inherit
        xonsh-direnv
        xontrib-abbrevs
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
