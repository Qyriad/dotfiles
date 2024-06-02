# vim: tabstop=4 shiftwidth=0 noexpandtab
{
	system,
	inputs, # should be flake inputs
}: let
	inherit (inputs.nixpkgs) lib;

	pkgs = import inputs.nixpkgs {
		inherit system;
		overlays = [ inputs.self.overlays.default ];
	};

in {
	packages = lib.filterAttrs (lib.const lib.isDerivation) pkgs.qyriad;
	# Truly dirty hack. This will let us transparently refer to overriden
	# or not overriden packages in nixpkgs, as flake.packages.foo is preferred over
	# flake.legacyPackages.foo by commands like `nix build`.
	legacyPackages = pkgs;
}
