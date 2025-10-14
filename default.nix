# vim: shiftwidth=4 tabstop=4 noexpandtab
{ ... } @ calledInputs: let
	inputs = import ./nixos/inputs.nix calledInputs;
	HOSTNAME = builtins.getEnv "HOSTNAME";

	locked = let
		flakedir = builtins.dirOf ./flake.nix |> toString;
		flakeref = "git+file:${flakedir}";
		flake = builtins.getFlake flakeref;
	in import ./default.nix flake.inputs;

	#
	# Initialize inputs as needed.
	#

	lib = import (inputs.nixpkgs + "/lib");

	mkVersionSuffix = pkgTree: let
		lastModifiedDate = lib.substring 0 8 pkgTree.lastModifiedDate;
		rev = pkgTree.shortRev or pkgTree.dirtyShortRev;
	in "-pre${lastModifiedDate}-${rev}";

	lixVersionSuffix = let
		version = lib.importJSON (inputs.lix + "/version.json");
	in lib.optionalString version.official_release (mkVersionSuffix inputs.lix);

	lix-module = import (inputs.lix-module + "/module.nix") {
		lix = inputs.lix;
		versionSuffix = lixVersionSuffix;
	};

	# Establish outputs.

	overlays = let
		overlay = import ./nixos/make-overlay.nix {
			inherit lib;
			inherit (inputs)
				agenix
				qyriad-nur
				niz
				log2compdb
				pzl
				cappy
				git-point
				xil
				xonsh-source
				nil-source
			;
		};
	in [
		overlay
	];

	keepModule = { lib, ... }: {
		imports = [ ./nixos/modules/keep-paths.nix ];

		nixpkgs.overlays = overlays;

		storePathsToKeep = inputs;
	};

	qlib = import ./nixos/qlib.nix { inherit lib; };

	#mkConfig = 
	#	system:
	#	nixosModules: let
	#		system' = lib.systems.elaborate system;
	#
	#		mkConfigFn = {
	#			linux = qlib.nixosSystem;
	#			darwin = qlib.darwinSystem;
	#		};
	#
	#		configuration = { ... }: {
	#			imports = nixosModules ++ [
	#				lix-module
	#				keepModule
	#			];
	#		};
	#	in mkConfigFn.${system'.parsed.kernel.name} {
	#		inherit system configuration;
	#	}
	#;

	nixosConfigurations = rec {
		#yuki = mkConfig "x86_64-linux" [
		#	./nixos/yuki.nix
		#];
		yuki = qlib.mkSystemConfiguration {
			inherit (inputs) nixpkgs nix-darwin;
			system = "x86_64-linux";
			configurations = { ... }: {
				imports = [
					./nixos/yuki.nix
					inputs.lix-module.nixosModules.default
					keepModule
				];
			};
		};
		Yuki = yuki;
	};

	nixos = nixosConfigurations.${HOSTNAME} or (
		throw "no NixOS configuration for detected hostname ${HOSTNAME}"
	);

in {
	inherit overlays;
	inherit nixosConfigurations;
	inherit nixos;

	# For exploration mostly. Will re-fetch.
	inherit locked;
}


#let
#	fetchGithub = path: fetchGit "https://github.com/${path}";
#in {
#	pkgs ? import <nixpkgs> { },
#	lib ? pkgs.lib,
#	nix-darwin ? fetchGit "https://github.com/LnL7/nix-darwin",
#	agenix ? fetchGithub "ryantm/agenix",
#	qyriad-nur ? fetchGit "https://github.com/Qyriad/nur-packages",
#	niz ? fetchGit "https://github.com/Qyriad/niz",
#	log2compdb ? fetchGit "https://github.com/Qyriad/log2compdb",
#	pzl ? fetchGithub "Qyriad/pzl",
#	xil ? fetchGithub "Qyriad/xil",
#	git-point ? fetchGithub "Qyriad/git-point",
#	crane ? fetchGithub "ipetkov/crane",
#	lix ? fetchGit "https://git.lix.systems/lix-project/lix",
#	lix-module ? fetchGit "https://git.lix.systems/lix-project/nixos-module",
#	xonsh-source ? fetchGithub "xonsh/xonsh",
#} @ inputs: let
#	inherit (pkgs) lib system;
#
#	lixModule = import (lix-module + "/module.nix") {
#		inherit lix;
#	};
#
#	qlib = import ./nixos/qlib.nix { inherit (pkgs) lib; };
#
#	scope = import ./nixos/make-scope.nix {
#		inherit
#			pkgs
#			lib
#			qyriad-nur
#			niz
#			log2compdb
#			pzl
#			git-point
#			xil
#			xonsh-source
#			crane
#		;
#	};
#
#	overlay = import ./nixos/make-overlay.nix {
#		inherit
#			lib
#			qyriad-nur
#			niz
#			log2compdb
#			pzl
#			git-point
#			xil
#			xonsh-source
#		;
#		getScope = pkgs: scope;
#	};
#
#	overlay-module = { ... }: {
#		nixpkgs.overlays = [ overlay ];
#	};
#
#	host-module = let
#		hostname = builtins.getEnv "HOSTNAME";
#	in ./nixos/${lib.strings.toLower hostname}.nix;
#
#	nixos = qlib.nixosSystem {
#		inherit system;
#		configuration = { ... }: {
#			imports = [
#				overlay-module
#				host-module
#				lixModule
#			];
#		};
#	};
#
#in {
#	inherit nixos;
#}
#
#	#nixos = pkgs.path + "/nixos";
#	#
#	#scope = import ./nixos/make-scope.nix {
#	#	inherit
#	#		pkgs
#	#		lib
#	#		qyriad-nur
#	#		niz
#	#		log2compdb
#	#		pzl
#	#		xil
#	#		git-point
#	#		crane
#	#		#lix
#	#		#lix-module
#	#	;
#	#};
#	#
#	#overlay = final: prev: {
#	#	qyriad = scope // {
#	#		lib = qlib;
#	#	};
#	#	inherit qlib;
#	#};
#
##in import <nixpkgs> { overlays = [ (builtins.getFlake "qyriad").overlays.default ]; }
#
##in {
##	darwinConfigurations = rec {
##		keyleth = import nix-darwin {
##			nixpkgs = pkgs.path;
##			configuration = { ... }: {
##				imports = [
##					./nixos/keyleth.nix
##				];
##			};
##		};
##	};
##
##	packages = scope;
##	lib = qlib;
##}
#
##{
##	pkgs ? import <nixpkgs> { },
##}:
##let
##	inherit (pkgs) lib;
##
##	lockFile = builtins.fromJSON (builtins.readFile ./flake.lock);
##	# lockFile but the parts that matter.
##	lockFile' = lib.mapAttrs (k: v: v.locked) lockFile.nodes;
##
##	getLockedUrl = locked:
##		"https://github.com/archive/${locked.owner}/${locked.repo}/${locked.rev}.tar.gz"
##	;
##
##	mkEachFlakeInput = lib.mapAttrs (name: locked: let
##		fetched = fetchTarball {
##			url = getLockedUrl locked;
##			sha256 = locked.narHash;
##		};
##	in
##		fetched
##	);
##
##	flakeInputs = mkEachFlakeInput lockFile';
##
##	qyriad-nur = import flakeInputs.qyriad-nur { };
##
##in {
##	nix-helpers = pkgs.callPackage ./nixos/pkgs/nix-helpers.nix { };
##	xonsh = pkgs.callPackage ./nixos/pkgs/xonsh {
##		inherit (qyriad-nur) python-pipe xontrib-abbrevs xonsh-direnv;
##	};
##}
##
###	flakeref = builtins.getFlake (toString ./.);
###	mkForSystem = self: { system ? builtins.currentSystem }:
###		self // {
###			packages = self.packages.${system};
###			legacyPackages = self.legacyPackages.${system};
###		}
###	;
###in
###	flakeref // {
###		__functor = mkForSystem;
###	}
