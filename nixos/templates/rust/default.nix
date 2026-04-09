{
	pkgs ? import <nixpkgs> { },
	qpkgs ? let
		src = fetchTree (builtins.parseFlakeRef "github:Qyriad/nur-packages");
	in import src { inherit pkgs; },
	clangStdenv ? pkgs.clangStdenv,
}: let
	inherit (qpkgs) lib;

	PKGNAME = qpkgs.callPackage ./package.nix { inherit clangStdenv; };

	byStdenv = lib.mapAttrs (stdenvName: stdenv: let
		withStdenv = PKGNAME.override { inherit stdenv; };
		PKGNAME' = withStdenv.overrideAttrs (prev: {
			pname = "${prev.pname}-${stdenvName}";
		});
	in PKGNAME') qpkgs.validStdenvs;

in PKGNAME.overrideAttrs (prev: lib.recursiveUpdate prev {
	passthru = { inherit byStdenv; };
})
