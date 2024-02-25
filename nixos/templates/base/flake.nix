{
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let

      pkgs = import nixpkgs { inherit system; };

      package = pkgs.callPackage ./package.nix { };

    in {
      packages.default = package;
      devShells.default = pkgs.mkShell {
        inputsFrom = [
          package
        ];
      };
    }) # eachDefaultSystem
  ; # outputs
}
