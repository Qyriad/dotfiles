info: final: prev:

rec {
  inherit (builtins) attrValues attrNames getFlake typeOf;
  qyriad = getFlake "qyriad";
  nixpkgs = getFlake "nixpkgs";
  nixpkgs-master = getFlake "github:NixOS/nixpkgs/master";
  nixpkgs-unstable = getFlake "github:NixOS/nixpkgs/nixpkgs-unstable";
  fenix = getFlake "github:nix-community/fenix";
  pkgs = import nixpkgs {
    system = info.currentSystem;
    overlays = attrValues qyriad.overlays;
  };
  nixos = qyriad.nixosConfigurations.${builtins.getEnv "HOSTNAME"};
  inherit (pkgs) lib qlib;
  f = builtins.getFlake "git+file:${builtins.getEnv "PWD"}";
  #local = import ./. { };
  local = import (builtins.getEnv "PWD") { };
  currentSystem = info.currentSystem;
  system = info.currentSystem;
}
