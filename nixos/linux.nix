# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, pkgs, lib, ... }:

{
	# Bootloader.
	boot.loader = {
		systemd-boot.enable = true;
		efi.canTouchEfiVariables = true;
		efi.efiSysMountPoint = "/boot/efi";
	};

	# We want sysrqs to work.
	#boot.kernelParams = [ "sysrq_always_enabled" ];
	boot.kernel.sysctl = {
		"kernel.sysrq" = "1";
	};

	# Yes mount /tmp as a tmpfs.
	boot.tmp.useTmpfs = true;

	services.smartd = {
		enable = true;
		autodetect = true;
	};

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
			# Make the nix-daemon not kill our computer, at all costs.
			IOSchedulingClass = lib.mkForce "idle";
			IOSchedulingPriority = lib.mkForce 7; # Lowest priority.
		};
	};

	services.dbus.implementation = "dbus";

	# Update timezone based on our location.
	services.localtimed.enable = true;
	services.geoclue2.enable = true;

	services.resolved.enable = true;
	networking.networkmanager.enable = true;
	networking.networkmanager.dns = "systemd-resolved";

	services.tailscale = {
		enable = true;
		useRoutingFeatures = "both";
	};
	systemd.services.tailscaled.serviceConfig = {
		# Tailscaled is a biiiit too logspamy, and it's pretty stable.
		# We'll shove its logs to /var/log instead of our system journal.
		StandardOutput = "file:/var/log/tailscaled.log";
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

	## Avahi is on most systems by default but not NixOS, it's quite useful to have mDNS support.
	#services.avahi = {
	#	enable = true;
	#
	#	# Enable support for resolving names from other systems over mDNS.
	#	nssmdns4 = true;
	#
	#	# Enable support for other systems resolving us via mDNS.
	#	publish = {
	#		enable = true;
	#		addresses = true;
	#	};
	#};

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
		package = pkgs.neovim-unwrapped.overrideAttrs {
			separateDebugInfo = true;
		};
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
	systemd.services.nixseparatedebuginfod.serviceConfig = {
		PrivateTmp = lib.mkForce false;
	};
	systemd.services.ModemManager.serviceConfig = {
		PrivateTmp = lib.mkForce false;
	};
	systemd.services.cups.serviceConfig = {
		PrivateTmp = lib.mkForce false;
	};
	systemd.services.power-profiles-daemon.serviceConfig = {
		PrivateTmp = lib.mkForce false;
	};
	systemd.services.upower.serviceConfig = {
		PrivateTmp = lib.mkForce false;
	};
	systemd.services.nscd.serviceConfig = {
		PrivateTmp = lib.mkForce false;
	};
	systemd.services.geoclue.serviceConfig = {
		PrivateTmp = lib.mkForce false;
	};

	systemd.user.services.waydroid-session = lib.mkIf config.virtualisation.waydroid.enable {
		serviceConfig = {
			Type = "simple";
			ExecStart = "${lib.getExe pkgs.waydroid} session start";
			ExecStop = "${lib.getExe pkgs.waydroid} session stop";
		};
	};

	security.wrappers."dmesg" = {
		owner = "root";
		group = "users";
		source = lib.getExe' pkgs.util-linux "dmesg";
		capabilities = "cap_syslog+ep";
		permissions = "u+r,g+rx,o+r";
	};

	# Other packages we want available on Linux systems.
	environment.systemPackages = with pkgs; [
		efibootmgr
		efivar
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
		diffoscope
		rpm
		binutils
		lsof
		iotop
		difftastic
		qyriad.strace-with-colors
		qyriad.intentrace
		ltrace
		bpftrace
		exfatprogs
		caligula
		trashy
		socat
		# Let us use our yubikey with age.
		age-plugin-yubikey
		yubikey-manager
		systeroid
		poke
		libtree
		lurk
		qyriad.cappy
	]
	++ lib.optionals config.services.smartd.enable [
		pkgs.smartmontools
	]
	++ config.systemd.packages # I want system services to also be in /run/current-system please.
	++ config.services.udev.packages # Same for udev...
	++ config.fonts.packages # and fonts...
	++ config.console.packages; # and including console fonts too.
}
