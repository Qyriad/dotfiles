# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, lib, pkgs, modulesPath, ... }:

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

	networking.hostName = "Yuki";

	services.fwupd.enable = true;

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
	];

	environment.enableDebugInfo = true;
	environment.extraOutputsToInstall = [
		"dev"
	];

	services.freshrss = {
	};

	virtualisation.waydroid.enable = true;

	systemd.user.services.capturecard-loopback = let
		pw-loopback = lib.getExe' config.services.pipewire.package "pw-loopback";
		capture = "alsa_input.usb-AVerMedia_Live_Gamer_Ultra-Video_5202418300266-02.analog-stereo";
		playback = "alsa_output.usb-Focusrite_Scarlett_Solo_USB_Y7Y663P27FB970-00.HiFi__Line1__sink";
	in {
		serviceConfig = {
			Type = "simple";
			ExecStart = "${pw-loopback} -C ${capture} -P ${playback} -n loopback.capturecard";
		};
	};

	services.samba = {
		enable = true;
		openFirewall = true;
		shares = {
			public = {
				path = "/";
				"read only" = false;
				"browsable" = "yes";
			};
		};
		nsswins = true;
		extraConfig = ''
		    workgroup = WORKGROUP
			server string = yuki
			netbios name = yuki
			security = user
			#use sendfile = yes
			#max protocol = smb2
			# note: localhost is the ipv6 localhost ::1
			hosts allow = 192.168.50. 127.0.0.1 localhost
			hosts deny = 0.0.0.0/0
			guest account = nobody
			map to guest = bad user
		'';
	};

	nix.buildMachines = let
		ashyn = {
			hostName = "ashyn";
			system = "aarch64-linux";
			protocol = "ssh-ng";

		};
	in [
		ashyn
	];

	nix.distributedBuilds = true;

	environment.systemPackages = with pkgs; [
		makemkv
		valgrind
	];

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "22.11"; # Did you read the comment?
}
