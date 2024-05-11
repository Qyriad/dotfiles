let
  inherit (builtins) getFlake currentSystem;
  nixpkgs = getFlake "nixpkgs";
  qyriad = getFlake "qyriad";
  pkgs = import nixpkgs { };
  lib = pkgs.lib;
  scope = pkgs // {
    inherit getFlake currentSystem;
    qlib = qyriad.lib;
    qyriad = qyriad.packages.${currentSystem} // qyriad.lib // {
      inherit (qyriad) lib;
    };
    f = getFlake ("git+file:" + (toString ./.));
  };
in
  target: import <xil/cleanCallPackageWith> scope target { }
