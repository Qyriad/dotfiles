# vim: shiftwidth=4 tabstop=4 noexpandtab

{ config, pkgs, ... }:

{
	fileSystems = let
		mountOpts = pkgs.qlib.genMountOpts {
			# Try to automatically mount, but don't block boot on it.
			auto = null;
			nofail = null;
			_netdev = null;
			"x-systemd.idle-timeout" = "300s";
			"x-systemd.mount-timeout" = "5s";
			"x-systemd.requires" = "network-online.target";
			"x-systemd.after" = "network-online.target";
			credentials = "/etc/secrets/shizue.cred";
			gid = "users";
			file_mode = "0764";
			dir_mode = "0775";
			vers = "3";
			#unix = null;
		};
	in {
		"/media/shizue/archive" = {
			device = "//shizue/Archive";
			fsType = "cifs";
			options = [ mountOpts ];
		};
		"/media/shizue/media" = {
			device = "//shizue/Media";
			fsType = "cifs";
			options = [ mountOpts ];
		};
	};


	# Enable GUI stuff.
	services.displayManager = {
		sddm.enable = true;
		sddm.autoNumlock = true;
		sddm.wayland.enable = true;
		defaultSession = "plasma";
	};

	# Use a Wayland KDE Plasma desktop environment, with systemd integration.
	services.desktopManager.plasma6 = {
		enable = true;
		enableQt5Integration = true;
	};

	# "A stop job is running for X11—" fuck off.
	systemd.services.display-manager.serviceConfig.TimeoutStopSec = "10";

	# Enabling a display manager automatically enables a text to speech daemon, in NixOS,
	# but we don't need this.
	services.speechd.enable = false;

	xdg.portal = {
		enable = true;
		#extraPortals = [
		#	pkgs.xdg-desktop-portal-gtk
		#	pkgs.xdg-desktop-portal-kde
		#];
	};

	# And also let Blink stuffs use Wayland.
	environment.sessionVariables = {
		NIXOS_OZONE_WL = "1";
	};

	# Enable sound with Pipewire.
	hardware.pulseaudio.enable = false;
	security.rtkit.enable = true;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
		#jack.enable = true;

		# use the example session manager (no others are packaged yet so this is enabled by default,
		# no need to redefine it in your config for now).
		#media-session.enable = true;
	};

	# FIXME: Is this necessary?
	services.libinput.enable = true;

	programs.gnupg.agent.pinentryPackage = pkgs.pinentry-qt;

	# Input method stuff.
	i18n.inputMethod = {
		enable = true;
		type = "fcitx5";

		fcitx5.waylandFrontend = true;

		fcitx5.addons = with pkgs; [
			fcitx5-mozc
			fcitx5-gtk
			kdePackages.fcitx5-qt
		];
	};

	# Enable udisks2.
	services.udisks2.enable = true;

	# A little bit cursed to put this in linux-gui, but generally this is the file that won't be sourced
	# for servers.
	networking.firewall.enable = false;

	nixpkgs.config.permittedInsecurePackages = [
		"electron-25.9.0" # For Obsidian
	];


	environment.systemPackages = with pkgs; [
		alacritty
		wezterm
		mpv
		wl-clipboard
		ksshaskpass
		opera
		obsidian
		qyriad.vesktop
		calibre
		kicad
		krita
		# TODO: possibly switch to sddm.extraPackages if it's added
		# https://github.com/NixOS/nixpkgs/pull/242009 (nixos/sddm: enable Wayland support)
		weston
		dsview
		pulseview
		ffmpeg-full
		aegisub
		cifs-utils
		nfs-utils
		ntfs3g
		#sequoia
		sioyek
		neochat
		fluffychat
		nheko
		element-desktop
		bitwig-studio
		curl
		kcachegrind
		signal-desktop
		thunderbird
		wtype
		seer
		#mattermost-desktop
		qyriad.cinny
		firefoxpwa
		#darling
		glibc.debug
		qt6.qtbase
		# Broken after the Python 3.12 migration for some reason. Check back later.
		#qemu_full
		#qemu-utils
		xorg.xlsclients
		kooha
		waypipe
		wayvnc
		wev
		seer
		obs-studio
		v4l-utils
		gajim
	];

	# GUI programs with NixOS modules that we can enable, instead of using environment.systemPackages.
	programs = {
		partition-manager.enable = true;
		firefox.enable = true;
		kdeconnect.enable = true;
	};

	# Used for noise suppression.
	#programs.noisetorch.enable = true;

	# Setup the terminal font we use, and make CJK render nicely.
	fonts.packages = with pkgs; [
		qyriad.nerdfonts
		noto-fonts-cjk-sans
	];
	fonts.fontconfig.defaultFonts.monospace = [
		"InconsolataGo Nerd Font Mono"
	];


	# Enable reasonable default fonts for unicode and emoji.
	fonts.enableDefaultPackages = true;
}
