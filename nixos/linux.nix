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

	# Update timezone based on our location.
	services.localtimed.enable = true;
	services.geoclue2.enable = true;

	networking.networkmanager.enable = true;

	services.tailscale = {
		enable = true;
		useRoutingFeatures = "both";
	};

	services.xserver = {
		layout = "us";
		xkbVariant = "";
	};

	# Enable CUPS for printing.
	services.printing.enable = true;

	services.openssh.enable = true;

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
		qt5.qtbase
	];
	services.nixseparatedebuginfod.enable = true;
}
