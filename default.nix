# vim: shiftwidth=4 tabstop=4 noexpandtab
let
	fetchGithub = path: fetchGit "https://github.com/${path}";
in {
	pkgs ? import <nixpkgs> { },
	lib ? pkgs.lib,
	nix-darwin ? fetchGit "https://github.com/LnL7/nix-darwin",
	agenix ? fetchGithub "ryantm/agenix",
	qyriad-nur ? fetchGit "https://github.com/Qyriad/nur-packages",
	niz ? fetchGit "https://github.com/Qyriad/niz",
	log2compdb ? fetchGit "https://github.com/Qyriad/log2compdb",
	pzl ? fetchGithub "Qyriad/pzl",
	xil ? fetchGithub "Qyriad/xil",
	git-point ? fetchGithub "Qyriad/git-point",
	crane ? fetchGithub "ipetkov/crane",
	lix ? fetchGit "https://git.lix.systems/lix-project/lix",
	lix-module ? fetchGit "https://git.lix.systems/lix-project/nixos-module",
	xonsh-source ? fetchGithub "xonsh/xonsh",
} @ inputs: let
	inherit (pkgs) lib system;

	qlib = import ./nixos/qlib.nix { inherit (pkgs) lib; };

	scope = import ./nixos/make-scope {
		inherit
			pkgs
			lib
			qyriad-nur
			niz
			log2compdb
			pzl
			git-point
			xil
			xonsh-source
			crane
		;
	};

	overlay = import ./nixos/make-overlay.nix {
		inherit
			lib
			qyriad-nur
			niz
			log2compdb
			pzl
			git-point
			xil
			xonsh-source
		;
		getScope = pkgs: scope;
	};

	overlay-module = { ... }: {
		nixpkgs.overlays = [ overlay ];
	};

	host-module = let
		hostname = builtins.getEnv "HOSTNAME";
	in ./nixos/${lib.strings.toLower hostname}.nix;

	nixos = qlib.nixosSystem {
		inherit system;
		configuration = { ... }: {
			imports = [
				overlay-module
				host-module
			];
		};
	};

in {
	inherit nixos;
}

	#nixos = pkgs.path + "/nixos";
	#
	#scope = import ./nixos/make-scope.nix {
	#	inherit
	#		pkgs
	#		lib
	#		qyriad-nur
	#		niz
	#		log2compdb
	#		pzl
	#		xil
	#		git-point
	#		crane
	#		#lix
	#		#lix-module
	#	;
	#};
	#
	#overlay = final: prev: {
	#	qyriad = scope // {
	#		lib = qlib;
	#	};
	#	inherit qlib;
	#};

#in import <nixpkgs> { overlays = [ (builtins.getFlake "qyriad").overlays.default ]; }

#in {
#	darwinConfigurations = rec {
#		keyleth = import nix-darwin {
#			nixpkgs = pkgs.path;
#			configuration = { ... }: {
#				imports = [
#					./nixos/keyleth.nix
#				];
#			};
#		};
#	};
#
#	packages = scope;
#	lib = qlib;
#}

#{
#	pkgs ? import <nixpkgs> { },
#}:
#let
#	inherit (pkgs) lib;
#
#	lockFile = builtins.fromJSON (builtins.readFile ./flake.lock);
#	# lockFile but the parts that matter.
#	lockFile' = lib.mapAttrs (k: v: v.locked) lockFile.nodes;
#
#	getLockedUrl = locked:
#		"https://github.com/archive/${locked.owner}/${locked.repo}/${locked.rev}.tar.gz"
#	;
#
#	mkEachFlakeInput = lib.mapAttrs (name: locked: let
#		fetched = fetchTarball {
#			url = getLockedUrl locked;
#			sha256 = locked.narHash;
#		};
#	in
#		fetched
#	);
#
#	flakeInputs = mkEachFlakeInput lockFile';
#
#	qyriad-nur = import flakeInputs.qyriad-nur { };
#
#in {
#	nix-helpers = pkgs.callPackage ./nixos/pkgs/nix-helpers.nix { };
#	xonsh = pkgs.callPackage ./nixos/pkgs/xonsh {
#		inherit (qyriad-nur) python-pipe xontrib-abbrevs xonsh-direnv;
#	};
#}
#
##	flakeref = builtins.getFlake (toString ./.);
##	mkForSystem = self: { system ? builtins.currentSystem }:
##		self // {
##			packages = self.packages.${system};
##			legacyPackages = self.legacyPackages.${system};
##		}
##	;
##in
##	flakeref // {
##		__functor = mkForSystem;
##	}
