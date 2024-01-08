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
		xonsh-direnv-src = {
			url = "github:74th/xonsh-direnv/1.6.1";
			flake = false;
		};
		xontrib-abbrevs-src = {
			url = "github:xonsh/xontrib-abbrevs/0.0.1";
			flake = false;
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
			inherit (nixpkgs.lib.attrsets) mapAttrs genAttrs recursiveUpdate;
			inherit (nixpkgs.lib.debug) traceVal traceSeq traceValSeq;
			inherit (builtins) attrNames;

			deepSeq = val: builtins.deepSeq val val;

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

			# Turns flake.${system}.packages (etc) into flake.packages (etc).
			flakeOutputsFor =
				# flake output schema :: attrset
				flake:
				# The name of that flake :: string
				flakeName:
				# "x86_64-linux"-style ("double") system string :: string
				system:

					let
						# Get the kinds of outputs this flake has.
						flakeTopLevelOutputNames = attrNames flake.outputs;

						# And for each of those, get that output for the system this function was passed,
						# but rename .default to .${flakeName}
						getFlakeOutput = outputName: flake.${outputName}.${system};

					in
						genAttrs flakeTopLevelOutputNames getFlakeOutput
			;

			flakesPerSystem =
				# "x86_64-linux"-style ("double") system string :: string
				system:
				# A map of names to flake attrsets. The name is used to rename .default outputs, if the flake
				# has any.
				flakes:

					mapAttrs (flakeName: flake:
						let
							flakeTopLevelOutputNames = traceVal (attrNames flake.outputs);

							# And for each of those, get that output for the system this function was passed.
							getFlakeOutput = outputName: flake.${outputName}.${system};

						in
							genAttrs (builtins.trace flakeTopLevelOutputNames (_: [ ])) getFlakeOutput
					) flakes # mapAttrs
			;

			mkPerSystemOutputs = system:
				let
					pkgs = import nixpkgs { inherit system; };

					qyriad-nur = import inputs.qyriad-nur {
						inherit pkgs;
					};

					xonshPkgs = pkgs.callPackage ./nixos/pkgs/xonsh {
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
							xonsh = xonshPkgs.xonsh;
							strace-process-tree = pkgs.python3Packages.callPackage ./nixos/pkgs/strace-process-tree.nix { };
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
							niz = niz.packages.${system}.default;
							log2compdb = log2compdb.packages.${system}.default;
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
