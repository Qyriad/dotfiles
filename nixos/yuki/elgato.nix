{
	pkgs,
	lib,
	...
}:

{
	services.udev.packages = let
		elgato-rules = pkgs.qyriad.runCommandMinimal "elgato-rules" {
			src = lib.fileset.toSource {
				root = ./.;
				fileset = lib.fileset.unions [
					./80-elgato.rules
					./80-elgato-notif.rules
				];
			};
			outDir = (placeholder "out") + "/lib/udev/rules.d";
			systemdRun = lib.getExe' pkgs.systemd "systemd-run";
			notifySend = lib.getExe' pkgs.libnotify "notify-send";
		} <| lib.dedent ''
			cp "$src/"* ./
			substituteInPlace "./80-elgato-notif.rules" \
				--replace-fail "@SYSTEMD_RUN@" "$notif" \
				--replace-fail "@NOTIFY_SEND@" "$notifySend"
			install --verbose -Dm644 "./80-elgato.rules" "--target-directory=$outDir"
			install --verbose -Dm644 "./80-elgato-notif.rules" "$outDir/80-elgato-notif.rules"
		'';

		# Unused for the moment.
		device-notifs = pkgs.qyriad.runCommandMinimal "device-notifs-rules" {
			src = ./90-device-notifs.rules;
			script = ./90-device-notifs.zsh;
			binDir = (placeholder "out") + "/bin";
			rulesDir = (placeholder "out") + "/lib/udev/rules.d";
			systemdRun = lib.getExe' pkgs.systemd "systemd-run";
			notifySend = lib.getExe' pkgs.libnotify "notify-send";
			zsh = lib.getExe pkgs.zsh;
			jq = lib.getExe pkgs.jq;
			dbusSend = lib.getExe' pkgs.dbus "dbus-send";
		} <| lib.dedent ''
			cp "$script" ./90-device-notifs.zsh
			substituteInPlace "./90-device-notifs.zsh" \
				--replace-fail "@ZSH@" "$zsh" \
				--replace-fail "@DBUS_SEND@" "$dbusSend" \
				--replace-fail "@SYSTEMD_NOTIFY" "$systemdNotify"

			cp "$src" ./90-device-notifs.rules
		'';
	in [
		elgato-rules
	];

	systemd.targets.ffcap-elgato = {
		description = "ffcap-elgato";
		unitConfig = {
			Conflicts = [ "shutdown.target" ];
		};
	};

	systemd.services.ffcap-elgato = {
		environment = {
			UDEVADM = "/run/current-system/sw/bin/udevadm";
			FFMPEG = "/run/current-system/sw/bin/ffmpeg";
			SYSTEMD_NOTIFY = "/run/current-system/sw/bin/systemd-notify";
		};
		serviceConfig = {
			Type = "notify";
			ExecStart = "/run/current-system/sw/bin/python3 /home/qyriad/.config/nixos/yuki/ffcap.py";
			SendSIGHUP = "yes";
			NotifyAccess = "all";
			SyslogLevelPrefix = true;
		};
		unitConfig.OnFailure = "ffcap-onfail.service";
		#wantedBy = [ "ffcap-elgato.target" ];
	};

	systemd.services.ffcap-onfail = {
		serviceConfig.Type = "oneshot";
		script = lib.dedent ''
			set -euxo pipefail
			echo 0 > /sys/bus/usb/devices/6-4/bConfigurationValue
			sleep 10s
			echo 1 > /sys/bus/usb/devices/6-4/bConfigurationValue
			echo "done!"
		'';
	};

	systemd.user.services.loopback-elgato = {
		script = lib.dedent ''
			exec /run/current-system/sw/bin/pw-loopback \
				-C "alsa_input.usb-Elgato_Game_Capture_HD60_S__0004C809C2000-03.analog-stereo" \
				-P default.audio.sink \
				-n loopback.capturecard
		'';
	};
}
