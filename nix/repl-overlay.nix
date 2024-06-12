info: final: prev:

rec {
  inherit (builtins) attrValues attrNames getFlake typeOf;
  qyriad = getFlake "qyriad";
  nixpkgs = getFlake "nixpkgs";
  pkgs = import nixpkgs {
    system = info.currentSystem;
    overlays = attrValues qyriad.overlays;
  };
  inherit (pkgs) lib qlib;
  f = builtins.getFlake "git+file:${builtins.getEnv "PWD"}";
  currentSystem = info.currentSystem;
}
