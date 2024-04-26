{
  pkgs,
  python-pipe,
  xontrib-abbrevs,
  xonsh-direnv,
  ...
 }:

let
  inherit (builtins) attrValues;

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
        requests
      ;
      inherit
        xonsh-direnv
        xontrib-abbrevs
        python-pipe
      ;
    } ++ old.propagatedBuildInputs;

    buildInputs = attrValues {
      inherit (pkgs.python3Packages)
        setuptools
      ;
    };
  });

in
  xonsh
