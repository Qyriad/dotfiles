# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, lib, pkgs, ... }:

{
	# Interface.
	options.storePathsToKeep = lib.mkOption {
		type = with lib.types; attrsOf pathInStore;
		default = { };
		description = ''
			Store paths to prevent from being garbage collected in this NixOS generation
			Useful for flake inputs.
		'';
		example = lib.literalExample ''
			{ inherit (inputs) nixpkgs; }
		'';
	};

	options.systemKeptPaths = lib.mkOption {
		type = lib.types.nullOr lib.types.package;
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
	config = {
		environment.pathsToLink = lib.mkIf (config.storePathsToKeep != { }) [ "/share/nix-support" ];

		systemKeptPaths = pkgs.qyriad.runCommandMinimal "system-kept-paths" {
			# Load bearing. keep-paths.sh does not work without structured attrs.
			__structuredAttrs = true;

			storePathNames = lib.attrNames config.storePathsToKeep;
			storePathValues = lib.map pkgs.writeClosure (lib.attrValues config.storePathsToKeep);
			inherit (config) echoKeptStorePaths;

		} <| lib.readFile ./keep-paths.sh;

		environment.systemPackages = lib.mkIf (config.storePathsToKeep != { }) [ config.systemKeptPaths ];
	};

}
