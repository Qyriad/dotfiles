{
	pkgs ? import <nixpkgs> { },
	qpkgs ? let
		src = fetchTarball "https://github.com/Qyriad/nur-packages/archive/main.tar.gz";
	in import src { inherit pkgs; },
	PKGNAME ? import ./default.nix { inherit pkgs qpkgs; },
}: let
	inherit (pkgs) lib;

	mkDevShell = PKGNAME: pkgs.callPackage PKGNAME.mkDevShell { };
	devShell = mkDevShell PKGNAME;
	byPythonVersion = lib.mapAttrs (lib.const mkDevShell) PKGNAME.byPythonVersion;

in devShell.overrideAttrs (prev: {
	passthru = lib.recursiveUpdate (prev.passthru or { }) {
		inherit byPythonVersion;
	};
})
