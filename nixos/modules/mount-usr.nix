{ config, lib, pkgs, ... }:
let
	cfg = config.system.mount-usr;

	MOUNT = lib.getExe' pkgs.util-linux "mount";
	UMOUNT = lib.getExe' pkgs.util-linux "umount";
	MOUNTPOINT = lib.getExe' pkgs.util-linux "mountpoint";
in
{
	# Interface.
	options = {
		system.mount-usr.enable = lib.mkEnableOption "Enable mounting /usr as /run/current-system";
	};

	# Implementation.
	config = lib.mkIf cfg.enable {

		# Eh, what's a little IFD between system closures.
		system.activationScripts."01-unmount-usr" = {
			deps = [ "stdio" ];
			supportsDryActivation = true;
			text = pkgs.replaceVars ./mount-usr-unmount.sh { inherit MOUNTPOINT UMOUNT; } |> builtins.readFile;
		};

		system.activationScripts."99-mount-usr" = {
			deps = [ "stdio" "usrbinenv" "var" "etc" "specialfs" "binsh" ];
			supportsDryActivation = true;
			text = pkgs.replaceVars ./mount-usr-mount.sh { inherit MOUNT; } |> builtins.readFile;
		};
	};
}
