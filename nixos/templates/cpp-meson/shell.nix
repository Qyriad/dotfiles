# Unlocked version. For locked inputs, use the flake.
{
	pkgs ? import <nixpkgs> { },
	PROJECT_NAME ? pkgs.callPackage ./package.nix { },
}:

pkgs.callPackage PROJECT_NAME.mkDevShell { }
