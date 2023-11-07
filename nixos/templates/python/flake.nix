{
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        inherit (builtins) attrValues;

        foo = pkgs.callPackage ./. { };

      in {
        packages.default = foo;
        devShells.default = pkgs.mkShell {
          inputsFrom = [
            foo
          ];
          packages = attrValues {
            inherit (pkgs)
              pyright
            ;
          };
        };
      }
    )
  ; # outputs
