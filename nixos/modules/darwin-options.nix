# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, pkgs, lib, ... }:

let
	inherit (lib) mdDoc types;
	cfg = config.homebrew-custom;
in
{
	options.homebrew-custom = {
		autoInstall = lib.mkOption {
			type = types.bool;
			default = false;
			description = mdDoc ''
				Automatically install Homebrew, if it is not already installed.
			'';
		};
	};

	#config = let
	#	homebrew-installer = pkgs.callPackage ./../pkgs/homebrew-installer.nix { };
	#	brewInstallerOverlay = prevPkgs: finalPkgs: {
	#		inherit homebrew-installer;
	#	};
	#in lib.mkIf cfg.autoInstall {
	#	nixpkgs.overlays = [
	#		brewInstallerOverlay
	#	];
	#
	#	system.activationScripts.preActivation.text = ''
	#		echo "checking if homebrew needs to be installed"
	#		set -euo pipefail
	#
	#
	#		needsInstall=
	#
	#		if [[ -e "/opt/homebrew/bin/brew" ]]; then
	#			# Check it actually runs
	#			brewVer="$(/opt/homebrew/bin/brew --version)"
	#			if ! [[ "$brewVer" =~ "^Homebrew.*" ]]; then
	#				needsInstall=1
	#			fi
	#		else
	#			needsInstall=1
	#		fi
	#
	#		if [[ -n "$needsInstall" ]]; then
	#			sudo -u qyriad /bin/bash "${lib.getBin homebrew-installer}/bin/homebrew-install.sh" --help
	#		fi
	#	'';
	#};
}
