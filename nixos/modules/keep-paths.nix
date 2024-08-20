# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, lib, pkgs, ... }:

{
	# Interface.
	options.storePathsToKeep = lib.mkOption {
		type = with lib.types; listOf pathInStore;
		default = [ ];
		description = ''
			Store paths to prevent from being garbage collected in this NixOS generation
			Useful for flake inputs.
		'';
		example = lib.literalExample ''
			[ inputs.nixpkgs ]
		'';
	};

	options.systemKeptPaths = lib.mkOption {
		type = lib.types.package;
		readOnly = true;
	};

	# Implementation.
	config = lib.mkIf (lib.lists.length config.storePathsToKeep > 0) {

		environment.pathsToLink = [ "/share/nix-support" ];

		systemKeptPaths = pkgs.qyriad.runCommandMinimal "system-kept-paths" {

			closureText = pkgs.writeClosure config.storePathsToKeep;

		} <| lib.trim ''
			mkdir -p "$out/share/nix-support"
			# All we need to prevent garbage collection of a store path is to have that
			# store path's text exist in the output of a derivation that is included in
			# our system derivation.
			# Easy enough!
			echo "preventing the following store paths from being garbage collected:"
			local storePathLine
			while IFS= read -r storePathLine; do
				echo "  $storePathLine"
			done < "$closureText"
			cp "$closureText" "$out/share/nix-support/propagated-build-inputs"
		'';

		environment.systemPackages = [ config.systemKeptPaths ];
	};
}
