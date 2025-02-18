# vim: shiftwidth=4 tabstop=4 noexpandtab

{
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		flake-utils.url = "github:numtide/flake-utils";
		agenix = {
			url = "github:ryantm/agenix";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nix-darwin = {
			url = "github:LnL7/nix-darwin";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		qyriad-nur = {
			url = "github:Qyriad/nur-packages";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.flake-utils.follows = "flake-utils";
		};
		niz = {
			url = "github:Qyriad/niz";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.flake-utils.follows = "flake-utils";
		};
		log2compdb = {
			url = "github:Qyriad/log2compdb";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.flake-utils.follows = "flake-utils";
		};
		pzl = {
			url = "github:Qyriad/pzl";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.flake-utils.follows = "flake-utils";
		};
		cappy = {
			url = "github:Qyriad/cappy";
			flake = false;
		};
		git-point = {
			url = "github:Qyriad/git-point";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.flake-utils.follows = "flake-utils";
		};
		xil = {
			url = "github:Qyriad/Xil";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.flake-utils.follows = "flake-utils";
		};
		lix = {
			url = "git+https://git.lix.systems/lix-project/lix";
			flake = false;
		};
		lix-module = {
			url = "git+https://git.lix.systems/lix-project/nixos-module";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.lix.follows = "lix";
			inputs.flake-utils.follows = "flake-utils";
		};
		mac-app-util = {
			url = "github:hraban/mac-app-util";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.flake-utils.follows = "flake-utils";
		};
		xonsh-source = {
			url = "github:xonsh/xonsh";
			flake = false;
		};
	};

	outputs = inputs @ {
		self,
		nixpkgs,
		flake-utils,
		nix-darwin,
		agenix,
		...
	}: let
		inherit (nixpkgs) lib;
		inherit (lib.attrsets) recursiveUpdate;

		qlib = import ./nixos/qlib.nix {
			inherit lib;
		};

		/** NixOS module for configs defined in this flake.
		 This is the only module that relies on flakeyness directly.
		*/
		flake-module = { lib, ... }: {
			imports = [ ./nixos/modules/keep-paths.nix ];

			nixpkgs.overlays = [ self.overlays.default ];

			# Prevent our flake input trees from being garbage collected.
			storePathsToKeep = lib.attrValues inputs;

			# Point "qyriad" to this here flake.
			nix.registry.qyriad = {
				from = { id = "qyriad"; type = "indirect"; };
				flake = self;
			};
		};

		# Wraps nixpkgs.lib.nixosSystem to generate a NixOS configuration, adding common modules
		# and special arguments.
		mkConfig =
			# "x86_64-linux"-style ("double") system string :: string
			system:
			# NixOS modules to add to this NixOS system configuration :: list
			nixosModules: let

				system' = lib.systems.elaborate system;

				# Use nixpkgs.lib.nixosSystem on Linux
				mkConfigFn = {
					linux = nixpkgs.lib.nixosSystem;
					darwin = nix-darwin.lib.darwinSystem;
				};

				modules = nixosModules ++ [
					inputs.lix-module.nixosModules.default
					flake-module
				] ++ lib.optionals system'.isDarwin [
					inputs.mac-app-util.darwinModules.default
				];

			in mkConfigFn.${system'.parsed.kernel.name} {
				inherit system modules;
			}
		;

		# Package outputs, which we want to define for multiple systems.
		perSystemOutputs = flake-utils.lib.eachDefaultSystem (system: let
			pkgs = import nixpkgs {
				inherit system;
				overlays = [ self.overlays.default ];
			};
			filterDerivations = lib.filterAttrs (lib.const lib.isDerivation);
		in {
			# This flake's packages output is just a re-export of the stuff
			# our overlay adds.
			packages = filterDerivations pkgs.qyriad;
			# Truly dirty hack. This will let us transparently refer to overriden
			# or not overriden packages in nixpkgs, as flake.packages.foo is preferred over
			# flake.legacyPackages.foo by commands like `nix build`.
			legacyPackages = pkgs;
		});

		# NixOS configuration outputs, which are each for one specific system.
		universalOutputs = {
			lib = qlib;

			overlays.default = import ./nixos/make-overlay.nix {
				inherit (nixpkgs) lib;
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
				;
			};

			nixosConfigurations = rec {
				futaba = mkConfig "x86_64-linux" [
					./nixos/futaba.nix
				];
				Futaba = futaba;

				yuki = mkConfig "x86_64-linux" [
					./nixos/yuki.nix
				];
				Yuki = yuki;

				#minimal-aarch64-linux = mkConfig "aarch64-linux" [
				#	./nixos/minimal.nix
				#];
			};
			darwinConfigurations = rec {
				Aigis = mkConfig "aarch64-darwin" [
					./nixos/darwin.nix
				];
				aigis = Aigis;

				Keyleth = mkConfig "aarch64-darwin" [
					./nixos/keyleth.nix
				];
				keyleth = Keyleth;

				Sodachi = mkConfig "aarch64-darwin" [
					./nixos/sodachi.nix
				];
				sodachi = Sodachi;
			};

			templates = {
				base = {
					path = ./nixos/templates/base;
					description = "barebones flake template";
				};
				rust = {
					path = ./nixos/templates/rust;
					description = "rust flake template";
				};
				meson-cpp = {
					path = ./nixos/templates/cpp-meson;
					description = "C++ Meson flake template";
				};
			};

		};

	in recursiveUpdate perSystemOutputs universalOutputs; # outputs
}
