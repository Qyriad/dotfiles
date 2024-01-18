# vim: shiftwidth=4 tabstop=4 noexpandtab

{
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		flake-utils.url = "flake-utils";
		nur.url = "github:nix-community/NUR";
		nixseparatedebuginfod = {
			url = "github:symphorien/nixseparatedebuginfod";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.flake-utils.follows = "flake-utils";
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
		caligula = {
			url = "github:ifd3f/caligula";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.flake-utils.follows = "flake-utils";
		};
		pzl = {
			url = "github:Qyriad/pzl";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.flake-utils.follows = "flake-utils";
		};
	};

	outputs = {
		self,
		nixpkgs,
		flake-utils,
		nur,
		nixseparatedebuginfod,
		niz,
		log2compdb,
		...
	} @ inputs:
		let
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
				modules:

					nixpkgs.lib.nixosSystem {
						inherit system;
						specialArgs.inputs = inputs;
						specialArgs.qyriad = recursiveUpdate self.outputs.packages.${system} self.outputs.lib;
						modules = modules ++ [
							nixseparatedebuginfod.nixosModules.default
							nur.nixosModules.nur
						];
					}
			;

			mkPerSystemOutputs = system:
				let
					pkgs = import nixpkgs { inherit system; };
					inherit (pkgs) lib;

					qyriad-nur = import inputs.qyriad-nur {
						inherit pkgs;
					};

					xonsh = pkgs.callPackage ./nixos/pkgs/xonsh {
						inherit (qyriad-nur)
							python-pipe
							xontrib-abbrevs
							xonsh-direnv
						;
					};

					non-flake-outputs = {
						packages = {
							nerdfonts = pkgs.callPackage ./nixos/pkgs/nerdfonts.nix { };
							udev-rules = pkgs.callPackage ./nixos/udev-rules { };
							nix-helpers = pkgs.callPackage ./nixos/pkgs/nix-helpers.nix { };
							inherit xonsh;
							inherit (qyriad-nur) strace-process-tree;
						};

						# Truly dirty hack. This will let us transparently refer to overriden
						# or not overriden packages in nixpkgs, as flake.packages.foo is preferred over
						# flake.legacyPackages.foo by commands like `nix build`.
						# We also slip our additional lib functions in here, so we can use them
						# with the rest of nixpkgs.lib.
						legacyPackages = recursiveUpdate
							nixpkgs.legacyPackages.${system}
							{
								lib = qlib;
								pkgs.lib = qlib;
							}
						;
					};

					# FIXME: flakesPerSystem is broken
					flake-outputs = {
						packages = {
							niz = import niz { inherit pkgs; };
							log2compdb = import log2compdb { inherit pkgs; };
							pzl = inputs.pzl.packages.${system}.default;
						};
					};
				in
					recursiveUpdate flake-outputs non-flake-outputs
			;
		in
			# Package outputs, which we want to define for multiple systems.
			recursiveUpdate (flake-utils.lib.eachDefaultSystem mkPerSystemOutputs)
			# NixOS configuration outputs, which are each for one specific system.
			{
				lib = qlib;

				nixosConfigurations = rec {
					futaba = mkConfig "x86_64-linux" [
						./nixos/futaba.nix
					];
					Futaba = futaba;

					yuki = mkConfig "x86_64-linux" [
						./nixos/yuki.nix
					];
					Yuki = yuki;
				};

				templates.base = {
					path = ./nixos/templates/base;
				};
			}
	; # outputs
}
