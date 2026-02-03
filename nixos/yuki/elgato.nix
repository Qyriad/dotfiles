{
	pkgs,
	lib,
	...
}:

{
	services.udev.packages = let
		elgato-rules = pkgs.qyriad.runCommandMinimal "elgato-rules" {
			src = ./80-elgato.rules;
			outDir = (placeholder "out") + "/lib/udev/rules.d";
			systemdRun = lib.getExe' pkgs.systemd "systemd-run";
			notifySend = lib.getExe' pkgs.libnotify "notify-send";
		} <| lib.dedent ''
			cp "$src" ./80-elgato.rules
			substituteInPlace "./80-elgato.rules" \
				--replace-fail "@SYSTEMD_RUN@" "$systemdRun" \
				--replace-fail "@NOTIFY_SEND@" "$notifySend"
			install --verbose -Dm644 "./80-elgato.rules" "--target-directory=$outDir"
		'';
	in [
		elgato-rules
		pkgs.systemd
	];

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
