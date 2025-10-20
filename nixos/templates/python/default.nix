{
	pkgs ? import <nixpkgs> { },
	python3Packages ? pkgs.python3Packages,
	qpkgs ? let
		src = fetchTarball "https://github.com/Qyriad/nur-packages/archive/main.tar.gz";
	in import src { inherit pkgs; },
}:

let
	inherit (pkgs) lib;
	PKGNAME = qpkgs.callPackage ./package.nix { inherit python3Packages; };

	byPythonVersion = qpkgs.pythonScopes
	|> lib.mapAttrs (_: python3Packages: PKGNAME.override { inherit python3Packages; })
	|> lib.filterAttrs (_: PKGNAME': !(PKGNAME'.meta.disabled or false));

in PKGNAME.overrideAttrs (prev: lib.recursiveUpdate prev {
	passthru = prev.passthru or { } // {
		inherit byPythonVersion;
	};
})
