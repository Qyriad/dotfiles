{ config, lib, pkgs, ... }:
let
	cfg = config.system.mount-usr;

	MOUNT = lib.getExe' pkgs.util-linux "mount";
	UMOUNT = lib.getExe' pkgs.util-linux "umount";
	MOUNTPOINT = lib.getExe' pkgs.util-linux "mountpoint";

	# TODO: warn or error on replacements that aren't used.
	replaceVarsInString = { ... }@replacements: s: replacements
	|> lib.foldlAttrs (acc: name: value: assert lib.strings.isConvertibleWithToString value; {
		names = acc.names ++ [ "@${toString name}@" ];
		values = acc.values ++ [ value ];
	}) { names = [ ]; values = [ ]; }
	|> ({ names, values }: lib.replaceStrings names values s)
	|> lib.splitLines
	|> lib.imap (i: line: let
			matches = lib.match ''.*@([A-Za-z0-9_]+)@.*'' line;
			joined = lib.concatStringsSep ", " matches;
			msg = "line ${toString i} has unreplaced variable(s): ${joined}";
	in assert lib.assertMsg (matches == null) msg; line)
	|> lib.joinLines
	;
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
			text = builtins.readFile ./mount-usr-unmount.sh
			|> replaceVarsInString { inherit MOUNTPOINT UMOUNT; };
		};

		systemd.services."umount-usr-before-shutdown" = {
			enableDefaultPath = false;
			path = [ pkgs.util-linux ];
			before = [ "shutdown.target" "umount.target" ];
			wantedBy = [ "shutdown.target" "umount.target" ];
			ExecStart = "${UMOUNT} --verbose --no-canonicalize --recursive --lazy /usr";
			unitConfig = {
				DefaultDependencies = false;
			};
			serviceConfig = {
				Type = "oneshot";
				Restart = "no";
				RemainAfterExit = true;
			};
		};

		systemd.services."mount-usr-after-activation" = {
			description = "Mount /usr after activation";
			serviceConfig = {
				Type = "oneshot";
				ExecStart = lib.getExe <| pkgs.writeShellApplication {
					name = "mount-usr-mount.sh";
					text = builtins.readFile ./mount-usr-mount.sh
					|> replaceVarsInString { inherit MOUNT; };
				};
			};
			unitConfig.ConditionPathExists = "/run/current-system";
			wantedBy = [ "sysinit.target" ];
			after = [ "sysinit.target" ];
		};
	};
}
