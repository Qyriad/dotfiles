info: final: prev:

rec {
  # Things I don't want to have to type `builtins.` before.
  inherit (builtins) attrValues attrNames getFlake parseFlakeRef flakeRefToString typeOf getEnv;

  # Mostly used for other stuff below,
  # but also handy in the repl if I want to avoid parentheses.
  PWD = getEnv "PWD";
  HOSTNAME = getEnv "HOSTNAME";

  # Bare flakes I use frequently enough.
  qyriad = getFlake "qyriad";
  nixpkgs = getFlake "nixpkgs";
  nixpkgs-master = getFlake "github:NixOS/nixpkgs/master";
  nixpkgs-unstable = getFlake "github:NixOS/nixpkgs/nixpkgs-unstable";
  fenix = getFlake "github:nix-community/fenix";

  currentSystem = info.currentSystem;
  system = info.currentSystem;

  # Instantiated forms of those flakes.
  pkgs = import nixpkgs {
    system = info.currentSystem;
    overlays = attrValues qyriad.overlays;
  };
  fenixLib = import fenix { inherit pkgs; };

  # `pkgs.lib` is soooooo much typing.
  inherit (pkgs) lib qlib stdenv;

  nixos = qyriad.nixosConfigurations.${HOSTNAME};
  darwin = qyriad.darwinConfigurations.${HOSTNAME};

  # Stuff that lets me inspect the current directory easily.
  f = getFlake "git+file:${PWD}";
  flakePackages = f.packages.${currentSystem};
  local = qlib.importAutocall PWD;
  shell = qlib.importAutocall (PWD + "/shell.nix");
}
