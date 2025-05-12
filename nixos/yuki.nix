# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, pkgs, lib, modulesPath, ... }:

{
	imports = [
		./yuki-hardware.nix
		./common.nix
		./linux.nix
		./linux-gui.nix
		./dev.nix
		./resources.nix
		./mount-shizue.nix
		./modules/package-groups.nix
		(modulesPath + "/installer/scan/not-detected.nix")
	];

	fileSystems."/media/data" = {
		device = "/dev/disk/by-label/YukiExtdata";
		fsType = "ext4";
		options = [ "discard" "nofail" ];
	};

	networking.hostName = "Yuki";

	environment.etc."xkb" = {
		enable = true;
		source = pkgs.qyriad.xkeyboard_config-patched-inet;
	};

	services.fwupd.enable = true;

	services.hardware.bolt.enable = true;

	hardware.openrazer = {
		# Probably.
		enable = false;
		users = let
			usersInUsersGroup = lib.filterAttrs (name: group:
				group.group == "users" || lib.elem "users" group.extraGroups
			) config.users.users;
		in lib.mapAttrsToList (_: user: user.name) usersInUsersGroup;
	};
	services.ratbagd.enable = true;

	# Options from our custom NixOS module in ./resources.nix
	resources = {
		memory = 32;
		cpus = 32;
	};

	# Non-NixOS-generated hardware configuration.
	hardware.cpu.amd.updateMicrocode = true;

	boot.kernelModules = [
		# For MakeMKV on blu rays.
		"sg"
		# For virtual /dev/video devices.
		"v4l2loopback"
	];

	boot.kernelPackages = pkgs.linuxPackages_6_12;

	environment.etc."modprobe.d/v4l2loopback.conf" = {
		text = (lib.trim ''
			options v4l2loopback video_nr=10,11,12 card_label=Virt0,Virt1,Virt2 exclusive_caps=1,1,1
		'') + "\n";
	};

	environment.enableDebugInfo = true;
	environment.extraOutputsToInstall = [
		"dev"
	];

	services.freshrss = {
	};

	virtualisation.waydroid.enable = true;

	services.pipewire.extraConfig.pipewire = {
		"10-allowed-rates" = {
			"default.clock.allowed-rates" = [ 44100 48000 ];
		};
		# FIXME: figure out what of these are actually necessary/useful.
		"10-capturecard-loopback-module"."context.modules" = let
			capturecard-loopback-module = {
				name = "libpipewire-module-loopback";
				args = {
					"capture.props" = {
						"node.name" = "AverMediaCapture";
						"node.nick" = "Capturecard Audio Loopback";
						"node.description" = "loopback-capturecard-capture";
						"stream.capture.source" = true;
						"target.object" = "alsa_input.usb-AVerMedia_Live_Gamer_Ultra-Video_5202418300266-02.iec958-stereo";
						"media.class" = "Stream/Input/Audio";
						# "port.group" = "capture";
						"application.name" = "QyriadConfig";
						"application.id" = "QyriadConfig";
						"media.role" = "Game";
						"node.group" = "qyriad.loopback.capturecard";
						"node.loop.name" = "data-loop.0";
					};
					"playback.props" = {
						"node.name" = "AverMediaPlayback";
						"node.nick" = "Capturecard Audio Loopback";
						"node.description" = "AVerMedia Live Gamer Ultra (Audio Loopback)";
						"node.virtual" = false;
						"monitor.channel-volumes" = true;
						"stream.capture.sink" = true;
						"media.class" = "Stream/Output/Audio";
						"media.type" = "Audio";
						#"port.group" = "stream.0";
						 "port.group" = "playback";
						"application.name" = "QyriadConfig";
						"application.id" = "QyriadConfig";
						"media.category" = "Playback";
						"media.name" = "AVerMedia Audio Loopback";
						"media.role" = "Game";
						"node.group" = "qyriad.loopback.capturecard";
						"node.loop.name" = "data-loop.0";
					};
				};
			};
		in [
			capturecard-loopback-module
		];
	};
	services.pipewire.extraConfig.pipewire-pulse = {
		"10-min-req" = {
			"pulse.min.req" = "1024/48000";
		};
	};

	services.samba = {
		enable = true;
		openFirewall = true;
		nsswins = true;
		settings.public = {
			path = "/";
			"read only" = false;
			"browsable" = "yes";
		};
		settings.global = {
			workgroup = "WORKGROUP";
			"server string" = "yuki";
			"netbios name" = "yuki";
			"security" = "user";
			"hosts allow" = "192.168.50. 127.0.0.1 localhost";
			"hosts deny" = "0.0.0.0/0";
			"guest account" = "nobody";
			"map to guest" = "bad user";
		};
	};

	nix.distributedBuilds = true;

	programs.gamemode.enable = true;

	programs.steam = {
		enable = true;
		remotePlay.openFirewall = true;
		dedicatedServer.openFirewall = true;
	};

	environment.systemPackages = with pkgs; [
		qyriad.steam-launcher-script
		config.programs.steam.package.run
		makemkv
		valgrind
		ryujinx
		shotcut
		davinci-resolve
		blender
		jetbrains.rust-rover
		config.boot.kernelPackages.perf
		obs-cmd
		odin2
		qyriad.nvtop-yuki
	];

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "22.11"; # Did you read the comment?
}
