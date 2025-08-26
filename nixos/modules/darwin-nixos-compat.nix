# vim: shiftwidth=4 tabstop=4 noexpandtab

# This module assumes it is only included on Darwin!

{ lib, config, ... }:

let
	t = lib.types;

	namesToTry = [
		config.networking.localHostName
		config.networking.computerName
		config.networking.hostName
	];

	nonEmpty = s: s != "" && s != null;

	firstNonEmpty = lib.findFirst nonEmpty "unnamed" namesToTry;
in
{
	options = {
		# This option exists in NixOS but not in nix-darwin.
		system.name = lib.mkOption {
			type = t.str;
			default = firstNonEmpty;
		};
	};
}
