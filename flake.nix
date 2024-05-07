# vim: shiftwidth=4 tabstop=4 noexpandtab

{
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		flake-utils.url = "github:numtide/flake-utils";
		nix-darwin = {
			url = "github:LnL7/nix-darwin";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nur.url = "github:nix-community/NUR";
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
		caligula = {
			url = "github:ifd3f/caligula";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.flake-utils.follows = "flake-utils";
			inputs.rust-overlay.follows = "rust-overlay";
			inputs.naersk.follows = "naersk";
		};
		rust-overlay = {
			url = "github:oxalica/rust-overlay";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.flake-utils.follows = "flake-utils";
		};
		naersk = {
			url = "github:nix-community/naersk";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		pzl = {
			url = "github:Qyriad/pzl";
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
	};

	outputs = inputs @ {
		self,
		nixpkgs,
		flake-utils,
		nix-darwin,
		nur,
		...
	}: let
		inherit (nixpkgs.lib.attrsets) recursiveUpdate;

		qlib = import ./nixos/qlib.nix {
			inherit (nixpkgs) lib;
		};

		# Wraps nixpkgs.lib.nixosSystem to generate a NixOS configuration, adding common modules
		# and special arguments.
		mkConfig =
			# "x86_64-linux"-style ("double") system string :: string
			system:
			# NixOS modules to add to this NixOS system configuration :: list
			nixosModules: let

				system' = nixpkgs.lib.systems.elaborate system;

				# Use nixpkgs.lib.nixosSystem on Linux
				mkConfigFn = {
					linux = nixpkgs.lib.nixosSystem;
					darwin = nix-darwin.lib.darwinSystem;
				};

				specialArgs = {
					inherit inputs;
					qyriad = recursiveUpdate self.outputs.packages.${system} self.outputs.lib;
				};

				modules = nixosModules ++ [
					nur.nixosModules.nur
				];

			in mkConfigFn.${system'.parsed.kernel.name} {
				inherit system specialArgs modules;
			}
		;

		mkPerSystemOutputs = system: import ./nixos/per-system.nix {
			inherit system inputs qlib;
		};

		# Package outputs, which we want to define for multiple systems.
		perSystemOutputs = flake-utils.lib.eachDefaultSystem mkPerSystemOutputs;

		# NixOS configuration outputs, which are each for one specific system.
		universalOutputs = {
			lib = qlib;

			nixosConfigurations = rec {
				futaba = mkConfig "x86_64-linux" [
					./nixos/futaba.nix
				];
				Futaba = futaba;

				yuki = mkConfig "x86_64-linux" [
					./nixos/yuki.nix
					inputs.lix-module.nixosModules.default
				];
				Yuki = yuki;

				minimal-aarch64-linux = mkConfig "aarch64-linux" [
					./nixos/minimal.nix
				];
			};
			darwinConfigurations = {
				Aigis = mkConfig "aarch64-darwin" [
					./nixos/darwin.nix
				];
			};

			templates.base = {
				path = ./nixos/templates/base;
				description = "barebones flake template";
			};
		};

	in recursiveUpdate perSystemOutputs universalOutputs; # outputs
}
