# vim: shiftwidth=4 tabstop=4 noexpandtab
{
	pkgs ? import <nixpkgs> { },
}:
let
	inherit (pkgs) lib;

	lockFile = builtins.fromJSON (builtins.readFile ./flake.lock);
	# lockFile but the parts that matter.
	lockFile' = lib.mapAttrs (k: v: v.locked) lockFile.nodes;

	getLockedUrl = locked:
		"https://github.com/archive/${locked.owner}/${locked.repo}/${locked.rev}.tar.gz"
	;

	mkEachFlakeInput = lib.mapAttrs (name: locked: let
		fetched = fetchTarball {
			url = getLockedUrl locked;
			sha256 = locked.narHash;
		};
	in
		fetched
	);

	flakeInputs = mkEachFlakeInput lockFile';

	qyriad-nur = import flakeInputs.qyriad-nur { };

in {
	nix-helpers = pkgs.callPackage ./nixos/pkgs/nix-helpers.nix { };
	xonsh = pkgs.callPackage ./nixos/pkgs/xonsh {
		inherit (qyriad-nur) python-pipe xontrib-abbrevs xonsh-direnv;
	};
}

#	flakeref = builtins.getFlake (toString ./.);
#	mkForSystem = self: { system ? builtins.currentSystem }:
#		self // {
#			packages = self.packages.${system};
#			legacyPackages = self.legacyPackages.${system};
#		}
#	;
#in
#	flakeref // {
#		__functor = mkForSystem;
#	}
