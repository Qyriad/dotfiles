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
		users = config.modlib.usersInGroup "users" |> lib.mapAttrsToList (_: user: user.name);
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
		# For DDC/CI.
		"i2c-dev"
	];

	boot.kernelPackages = pkgs.linuxPackages_latest;

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
	# I don't need steam hardware support. This is enabled by default with
	# `programs.steam.enable`.
	# Priority exactly 1 stronger than the default.
	hardware.steam-hardware.enable = lib.mkForce false;

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
