# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, pkgs, qyriad, ... }:

{
	# Bootloader.
	boot.loader = {
		systemd-boot.enable = true;
		efi.canTouchEfiVariables = true;
		efi.efiSysMountPoint = "/boot/efi";
	};

	# Yes mount /tmp as a tmpfs.
	boot.tmp.useTmpfs = true;

	# Make the systemd stop timeout more reasonable.
	systemd.extraConfig = ''
		DefaultTimeoutStopSec=20
	'';

	systemd.slices.system-builder.sliceConfig = config.resources.builderSliceConfig;
	systemd.user.slices.user-builder.sliceConfig = config.resources.builderSliceConfig;

	# Make Nix builds not OOM my machine please.
	systemd.services.nix-daemon = {
		serviceConfig = {
			OOMScoreAdjust = "950";
			Slice = "system-builder.slice";
			MemoryPressureWatch = "on";
		};
		unitConfig = {
			ManagedOOMPressure = "kill";
			ManagedOOMPressureLimit = "85%";
		};
	};

	# Update timezone based on our location.
	services.localtimed.enable = true;
	services.geoclue2.enable = true;

	networking.networkmanager.enable = true;

	services.tailscale = {
		enable = true;
		useRoutingFeatures = "both";
	};

	services.xserver.xkb = {
		layout = "us";
		variant = "";
	};

	# Enable CUPS for printing.
	services.printing.enable = true;

	services.openssh.enable = true;

	# Avahi is on most systems by default but not NixOS, it's quite useful to have mDNS support.
	services.avahi = {
		enable = true;

		# Enable support for resolving names from other systems over mDNS.
		nssmdns4 = true;

		# Enable support for other systems resolving us via mDNS.
		publish = {
			enable = true;
			addresses = true;
		};
	};

	# Our normal user.
	users.users.qyriad = {
		isNormalUser = true;
		description = "Qyriad";
		extraGroups = [ "wheel" "networkmanager" "plugdev" "dialout" "video" "cdrom" ];
		shell = pkgs.zsh;
	};
	users.groups.plugdev = { };
	users.groups.video = { };
	users.groups.cdrom = { };

	nix.settings.trusted-users = [
		"root"
	];

	nix.settings.allowed-users = [
		"qyriad"
	];

	programs.zsh.enable = true;

	programs.gnupg.agent = {
		enable = true;
		enableSSHSupport = true;
	};

	programs.neovim = {
		enable = true;
		defaultEditor = true;
		withNodeJs = true;
	};

	services.udev.packages = [
		qyriad.udev-rules
	];

	# Other packages we want available on Linux systems.
	environment.systemPackages = with pkgs; [
		usbutils
		pciutils
		(gdb.override { enableDebuginfod = true; })
		qyriad.strace-process-tree
	];
	services.nixseparatedebuginfod.enable = true;
}
