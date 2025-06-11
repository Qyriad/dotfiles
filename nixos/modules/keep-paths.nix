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

	options.echoKeptStorePaths = lib.mkOption {
		type = lib.types.bool;
		default = true;
		description = ''
			Whether to echo the store paths kept by `options.storePathsToKeep` during build or not.
		'';
	};

	# Implementation.
	config = lib.mkIf (lib.lists.length config.storePathsToKeep > 0) {

		environment.pathsToLink = [ "/share/nix-support" ];

		systemKeptPaths = pkgs.qyriad.runCommandMinimal "system-kept-paths" {

			closureText = pkgs.writeClosure config.storePathsToKeep;
			inherit (config) echoKeptStorePaths;

		} <| lib.readFile ./keep-paths.sh;

		environment.systemPackages = [ config.systemKeptPaths ];
	};
}
