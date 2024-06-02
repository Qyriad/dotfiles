# vim: tabstop=4 shiftwidth=0 noexpandtab
{
	system,
	inputs, # should be flake inputs
	qlib,
}: let
	pkgs = import inputs.nixpkgs { inherit system; };
	inherit (pkgs) lib;

	scope = import ./make-scope.nix {
		inherit pkgs lib;
		inherit (inputs)
			qyriad-nur
			niz
			log2compdb
			pzl
			git-point
			xil
		;
	};

in {
	packages = lib.filterAttrs (lib.const lib.isDerivation) scope;
	# Truly dirty hack. This will let us transparently refer to overriden
	# or not overriden packages in nixpkgs, as flake.packages.foo is preferred over
	# flake.legacyPackages.foo by commands like `nix build`.
	legacyPackages = pkgs;
}
