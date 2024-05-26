info: final: prev:

rec {
  nixpkgs = builtins.getFlake "nixpkgs";
  pkgs = import nixpkgs { system = info.currentSystem; };
  inherit (pkgs) lib;
  qyriad = builtins.getFlake "qyriad";
  f = builtins.getFlake "git+file:${builtins.getEnv "PWD"}";
  currentSystem = info.currentSystem;
}
