{
	pkgs,
	lib,
	...
}:

{
	services.udev.packages = let
		elgato-rules = pkgs.qyriad.runCommandMinimal "elgato-rules" {
			src = ./70-elgato.rules;
			outDir = (placeholder "out") + "/lib/udev/rules.d";
		} <| lib.dedent ''
			install --verbose -Dm644 "$src" "--target-directory=$outDir"
		'';
	in [
		elgato-rules
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
