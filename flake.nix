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
			url = "github:nix-darwin/nix-darwin";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		qyriad-nur = {
			url = "github:Qyriad/nur-packages";
			flake = false;
		};
		niz = {
			url = "github:Qyriad/niz";
			flake = false;
		};
		log2compdb = {
			url = "github:Qyriad/log2compdb";
			flake = false;
		};
		pzl = {
			url = "github:Qyriad/pzl";
			flake = false;
		};
		cappy = {
			url = "github:Qyriad/cappy";
			flake = false;
		};
		git-point = {
			url = "github:Qyriad/git-point";
			flake = false;
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
		nil-source = {
			url = "github:oxalica/nil";
			flake = false;
		};
		disko = {
			url = "github:nix-community/disko/latest";
			inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
		};
		originfox-source = {
			url = "sourcehut:icewind/originfox?host=codeberg.org";
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

		qpkgsLib = import inputs.qyriad-nur { mode = "lib"; inherit lib; };

		/** NixOS module for configs defined in this flake.
		 This is the only module that relies on flakeyness directly.
		*/
		flake-module = lib.modules.importApply ./nixos/modules/flake-module.nix self;

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
					flake-module
					agenix.nixosModules.default
				] ++ lib.optionals system'.isLinux [
					inputs.lix-module.nixosModules.default
				] ++ lib.optionals system'.isDarwin [
					inputs.mac-app-util.darwinModules.default
					(inputs.lix-module.darwinModules.default or {
						nixpkgs.overlays = let
							lix-overlay = inputs.lix-module.overlays.default;
						in [ lix-overlay ];
					})
				];

			in mkConfigFn.${system'.parsed.kernel.name} {
				inherit system modules;
				# HACK: pass our combined lib to modules.
				specialArgs.lib = lib // qpkgsLib;
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

			# Whatever.
			apps.nix-flake-upgrade-most = let
				mostInputs = lib.removeAttrs inputs [ "nixpkgs" ] |> lib.attrNames;
				drv = pkgs.writeShellScriptBin "nix-flake-upgrade-most" (lib.trim ''
					set -euo pipefail
					niz flake update --commit-lock-file ${lib.concatStringsSep " " mostInputs}
					systemd-inhibit --what=sleep rebuild build
				'');
			in {
				program = lib.getExe drv;
				type = "app";
			};

			#checks = {
			#	nixosEvals = self.nixosConfigurations
			#	|> lib.mapAttrs (nixos: lib.deepSeq (toString nixos.config.system.build.toplevel) pkgs.empty)
			#	;
			#};
			#checks = self.nixosConfigurations
			#|> lib.mapAttrs (host: nixos: lib.deepSeq (toString nixos.config.system.build.toplevel) pkgs.empty);
			#checks.yuki = pkgs.empty.overrideAttrs (prev: {
			#	env = {
			#		yuki = let
			#			nixos = self.nixosConfigurations.yuki;
			#		in lib.seq (toString nixos.config.system.build.toplevel) nixos.config.system.build.toplevel.drvPath;
			#	};
			#});
		});

		# NixOS configuration outputs, which are each for one specific system.
		universalOutputs = {
			lib = let
				pkgs = import nixpkgs {
					overlays = [ self.overlays.default ];
				};
			in pkgs.qlib;

			overlays.main = import ./nixos/make-overlay.nix {
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
					nil-source
					tmux-source
					originfox-source
				;
			};
			overlays.killWrappers = import ./nixos/kill-wrappers-overlay.nix;

			overlays.default = lib.composeManyExtensions [
				self.overlays.main
				self.overlays.killWrappers
			];

			nixosConfigurations = rec {
				futaba = mkConfig "x86_64-linux" [
					./nixos/futaba.nix
				];
				Futaba = futaba;

				yuki = mkConfig "x86_64-linux" [
					./nixos/yuki
					inputs.disko.nixosModules.disko
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
				python = {
					path = ./nixos/templates/python;
					description = "our basic python template";
				};
				meson-cpp = {
					path = ./nixos/templates/cpp-meson;
					description = "C++ Meson flake template";
				};
			};

		};

	in recursiveUpdate perSystemOutputs universalOutputs; # outputs
}
