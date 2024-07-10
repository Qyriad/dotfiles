# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, pkgs, lib, ... }:

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

	systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

	systemd.slices.system-builder.sliceConfig = config.resources.builderSliceConfig;
	systemd.user.slices.user-builder.sliceConfig = config.resources.builderSliceConfig;

	# Make Nix builds not OOM my machine please.
	systemd.services.nix-daemon = {
		serviceConfig = {
			OOMScoreAdjust = "950";
			Slice = "system-builder.slice";
			MemoryPressureWatch = "on";
			ManagedOOMMemoryPressure = "kill";
			ManagedOOMMemoryPressureLimit = "85%";
			MemoryHigh = config.resources.builderSliceConfig.MemoryHigh;
			MemoryMax = config.resources.builderSliceConfig.MemoryMax;
			IOWeight = 20;
			MemoryAccounting = true;
			IOAccounting = true;
		};
	};

	services.dbus.implementation = "dbus";

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

	#boot.binfmt.emulatedSystems = [
	#	"aarch64-linux"
	#	#"armv6l-linux"
	#	#"armv7l-linux"
	#	#"i386-linux"
	#	#"i486-linux"
	#	#"i586-linux"
	#	#"i686-linux"
	#	#"mips-linux"
	#	#"mips64-linux"
	#	#"powerpc-linux"
	#	#"powerpc64-linux"
	#	#"riscv32-linux"
	#	#"riscv64-linux"
	#	#"sparc-linux"
	#];

	i18n.defaultLocale = "en_US.utf8";

	# Add ~/.local/bin to system path.
	environment.localBinInPath = true;

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

	documentation = {
		# Include -dev manpages
		#dev.enable = true;
		# Make apropos(1) work.
		man.generateCaches = true;
		# This fails with `cannot lookup '<nixpkgs>' in pure evaluation mode.
		# TODO: debug
		#nixos.includeAllModules = true;
	};

	programs.xonsh = {
		enable = true;
		package = pkgs.qyriad.xonsh;
	};

	environment.sessionVariables = {
		BASH_COMPLETIONS = "${pkgs.bash-completion}/share/bash-completion/bash_completion";
	};

	programs.zsh.enable = true;

	programs.neovim = {
		enable = true;
		defaultEditor = true;
	};

	programs.git = {
		enable = true;
		lfs.enable = true;
	};

	# Covered by nix-index, not that its integrations support our shell.
	programs.command-not-found.enable = false;

	services.udev.packages = [
		pkgs.qyriad.udev-rules
	];

	# Let us use our yubikey with age.
	services.pcscd.enable = true;

	services.nixseparatedebuginfod.enable = true;

	# Other packages we want available on Linux systems.
	environment.systemPackages = with pkgs; [
		usbutils
		pciutils
		(gdb.override { enableDebuginfod = true; })
		qyriad.strace-process-tree
		zps
		kmon
		# Needs AppKit on macOS?
		heh
		sysstat
		# apksigner dependency fails to build on macOS
		#diffoscope # Broken (again) in Nixpkgs. Check back later.
		rpm
		binutils
		lsof
		iotop
		difftastic
		qyriad.strace-with-colors
		ltrace
		bpftrace
		exfatprogs
		caligula
		trash-cli
		socat
		# Let us use our yubikey with age.
		age-plugin-yubikey
		yubikey-manager
		systeroid
	];
}
