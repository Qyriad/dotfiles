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

		systemd.services."mount-usr-after-activation" = {
			description = "Mount /usr after activation";
			serviceConfig = {
				Type = "oneshot";
				ExecStart = lib.getExe <| pkgs.writeShellApplication {
					name = "mount-usr-mount.sh";
					text = pkgs.replaceVars ./mount-usr-mount.sh { inherit MOUNT; } |> builtins.readFile;
				};
				ConditionPathExists = "/run/current-system";
			};
			wantedBy = [ "sysinit.target" ];
			after = [ "sysinit.target" ];
		};
	};
}
