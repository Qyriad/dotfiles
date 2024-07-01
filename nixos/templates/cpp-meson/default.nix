# Unlocked version. For locked inputs, use the flake.
{
	pkgs ? import <nixpkgs> { },
}:

pkgs.callPackage ./package.nix { }
