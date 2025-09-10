{
	pkgs ? import <nixpkgs> { },
	qpkgs ? let
		src = fetchTarball "https://github.com/Qyriad/nur-packages/archive/main.tar.gz";
	in import src { inherit pkgs; },
	PKGNAME ? import ./default.nix { inherit pkgs qpkgs; },
}: let
	inherit (pkgs) lib;

	mkDevShell = PKGNAME: qpkgs.callPackage PKGNAME.mkDevShell { };
	devShell = mkDevShell PKGNAME;

	byStdenv = lib.mapAttrs (lib.const mkDevShell) PKGNAME.byStdenv;

in devShell.overrideAttrs (prev: lib.recursiveUpdate prev {
	passthru = { inherit byStdenv; };
})
