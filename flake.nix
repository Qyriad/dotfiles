# vim: shiftwidth=4 tabstop=4 noexpandtab

{
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		flake-utils.url = "github:numtide/flake-utils";
		nixseparatedebuginfod.url = "github:symphorien/nixseparatedebuginfod";
		xonsh = {
			# ref=HEAD is apparently necessary: https://github.com/NixOS/nix/issues/3978#issuecomment-1663037086
			url = "git+file:/home/qyriad/.config?dir=nixos/pkgs/xonsh&ref=HEAD";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { self, nixpkgs, flake-utils, nixseparatedebuginfod, xonsh } @ inputs:
		let
			inherit (nixpkgs.lib.attrsets) genAttrs recursiveUpdate;
			inherit (builtins) attrNames;

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
					specialArgs.qyriad = self.outputs.packages.${system};
					modules = modules ++ [
						nixseparatedebuginfod.nixosModules.default
					];
				}
			;

			# Turns flake.${system}.packages (etc) into flake.packages (etc).
			flakeOutputsFor =
				# flake output schema :: attrset
				flake:
				# "x86_64-linux"-style ("double") system string :: string
				system:

				let
					# Get the kinds of outputs this flake has.
					flakeTopLevelOutputNames = attrNames flake.outputs;

					# And for each of those, get that output for the system this function was passed.
					getFlakeOutput = outputName: flake.${outputName}.${system};

				in
					genAttrs flakeTopLevelOutputNames getFlakeOutput
			;

			mkPerSystemOutputs = system:
				let
					pkgs = import nixpkgs { inherit system; };

					qyriad = self.outputs.${system};

					non-flake-outputs = {
						packages = {
							nerdfonts = pkgs.callPackage ./nixos/pkgs/nerdfonts.nix { };
							udev-rules = pkgs.callPackage ./nixos/udev-rules { };
							nix-helpers = pkgs.callPackage ./nixos/pkgs/nix-helpers.nix { };
						};
					};

					flake-outputs = flakeOutputsFor xonsh system;
				in
					recursiveUpdate flake-outputs non-flake-outputs
			;
		in
			# Package outputs, which we want to define for multiple systems.
			flake-utils.lib.eachDefaultSystem mkPerSystemOutputs
			// # NixOS configuration outputs, which are each for one specific system.
			{
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

				# Truly dirty hack. This will let us to transparently refer to overriden or not overriden
				# packages in nixpkgs, as flake.packages.foo is preferred over flake.legacyPacakges.foo.
				legacyPackages = nixpkgs.legacyPackages;
			}
	; # outputs
}
