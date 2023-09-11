{
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    xonsh-direnv-src = {
      url = "github:74th/xonsh-direnv/1.6.1";
      flake = false;
    };
    xontrib-abbrevs-src = {
      url = "github:xonsh/xontrib-abbrevs/0.0.1";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, xonsh-direnv-src, xontrib-abbrevs-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        inherit (pkgs.python3Packages) buildPythonPackage;

        xonsh-direnv = buildPythonPackage {
          pname = "xonsh-direnv";
          version = "1.6.1";
          src = xonsh-direnv-src;

          buildInputs = with pkgs; [
            direnv
          ];
        };

        xontrib-abbrevs = buildPythonPackage {
          pname = "xontrib-abbrevs";
          version = "0.0.1";
          src = xontrib-abbrevs-src;

          format = "pyproject";

          buildInputs = with pkgs.python3Packages; [
            setuptools
            wheel
            poetry-core
          ];
        };

        xonsh = pkgs.xonsh.overridePythonAttrs (old: {
          propagatedBuildInputs = with pkgs.python3Packages; [
            pip
            ipython
            psutil
            unidecode
            # Lets xonsh set its process title to "xonsh" instead of "python3.10", which is much less annoying
            # in my tmux window names.
            setproctitle
            xonsh-direnv
            xontrib-abbrevs
          ] ++ old.propagatedBuildInputs;

          buildInputs = with pkgs.python3Packages; [
            setuptools
          ];
        });
      in
      {
        packages = {
          inherit xonsh-direnv xontrib-abbrevs xonsh;
          default = xonsh;
        };
      }
    )
  ;
}
