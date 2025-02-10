# vim: shiftwidth=4 tabstop=4 noexpandtab

{ config, lib, pkgs, ... }:

{
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

	# Plasma Shell also seems to not deal well with other user services
	# crashing instead of stopping properly.
	# Leave the start timeout at the default 40 seconds, but decrease the
	# stop timeout to something real short.
	#systemd.user.services.plasma-plasmashell.serviceConfig = {
	#	TimeoutStartSec = "40";
	#	TimeoutStopSec = "10";
	#};
	# And tbh let's just shorten the stop timeout for all user units a bit.
	systemd.user.extraConfig = ''
		DefaultTimeoutStopSec=20
	'';

	# Enabling a display manager automatically enables a text to speech daemon, in NixOS,
	# but we don't need this.
	#services.speechd.enable = false;

	xdg.portal = {
		enable = true;
		#extraPortals = [
		#	pkgs.xdg-desktop-portal-gtk
		#	pkgs.xdg-desktop-portal-kde
		#];
		xdgOpenUsePortal = true;
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
		"olm-3.2.16" # For Cinny
		"jitsi-meet-1.0.8043" # For Element
	];

	package-groups = {
		music-production.enable = lib.mkDefault true;
		wayland-tools.enable = lib.mkDefault true;
	};

	environment.systemPackages = with pkgs; [
		libinput
		libva-utils
		alacritty
		wezterm
		# Backup.
		#konsole
		qyriad.mpv
		qyriad.obsidian
		pandoc
		qyriad.vesktop
		# For voice.
		discord
		calibre
		kicad
		krita
		olive-editor
		# TODO: possibly switch to sddm.extraPackages if it's added
		# https://github.com/NixOS/nixpkgs/pull/242009 (nixos/sddm: enable Wayland support)
		weston
		#dsview
		pulseview
		ffmpeg-full
		(lib.getBin x264)
		(lib.getBin x265)
		aegisub
		cifs-utils
		nfs-utils
		ntfs3g
		sequoia
		sioyek
		#neochat
		#fluffychat
		nheko
		element-desktop
		curl
		kcachegrind
		flamegraph
		signal-desktop
		thunderbird
		seer
		#mattermost-desktop
		#qyriad.cinny
		firefoxpwa
		#darling
		glibc.debug
		qt6.qtbase
		qemu_full
		qemu-utils
		xorg.xlsclients
		xorg.xset # Make OBS shut up.
		seer
		qyriad.obs-studio
		v4l-utils
		gajim
		inlyne
		tesseract
		smile
		gst_all_1.gstreamer
		libnotify
		chromium
		kdePackages.dragon
		kdePackages.filelight
		kdePackages.ffmpegthumbs
		kdePackages.kalgebra
		kdePackages.kcalc
		kdePackages.kcharselect
		kdePackages.kcolorchooser
		kdePackages.kcolorpicker
		kdePackages.kde-dev-scripts
		kdePackages.kde-dev-utils
		kdePackages.kdebugsettings
		kdePackages.kde-inotify-survey
		kdePackages.kdeplasma-addons
		kdePackages.kdf
		kdePackages.kfind
		kdePackages.kget
		kdePackages.kimageannotator
		kdePackages.kio-zeroconf
		kdePackages.kompare
		kdePackages.kontrast
		kdePackages.krdc
		kdePackages.ksshaskpass
		kdePackages.ksystemlog
		kdePackages.plasma-disks
		kdePackages.sddm-kcm
		kdePackages.flatpak-kcm
		kdePackages.sweeper
	] ++ lib.optionals config.services.pipewire.enable [
		pavucontrol
		lxqt.pavucontrol-qt
		pwvucontrol
		wayfarer
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
		nerd-fonts.inconsolata-go
		noto-fonts-cjk-sans
	];


	# Enable reasonable default fonts for unicode and emoji.
	fonts.enableDefaultPackages = true;
}
