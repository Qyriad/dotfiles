# vim: shiftwidth=4 tabstop=4 noexpandtab

{ config, pkgs, qyriad, ... }:

{
	fileSystems = let
		mountOpts = qyriad.genMountOpts {
			# Try to automatically mount, but don't block boot on it.
			auto = null;
			nofail = null;
			_netdev = null;
			"x-systemd.idle-timeout" = "300s";
			"x-systemd.mount-timeout" = "5s";
			"x-systemd.requires" = "network-online.target";
			credentials = "/etc/secrets/shizue.cred";
			gid = "users";
			file_mode = "0764";
			dir_mode = "0775";
			vers = "3.1.1";
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

	# On Yuki this costs less than a GiB. Let's try it for now.
	#environment.enableDebugInfo = true;
	#environment.extraOutputsToInstall = [
	#	"dev"
	#];


	# Enable GUI stuff.
	# Yes this says xserver. Yes this we're using Wayland. That's correct.
	# https://github.com/NixOS/nixpkgs/issues/94799
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
	sound.enable = true;
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
	services.xserver.libinput.enable = true;

	programs.gnupg.agent.pinentryPackage = pkgs.pinentry-qt;

	# Input method stuff.
	i18n.inputMethod = {
		enabled = "fcitx5";

		fcitx5.waylandFrontend = true;

		fcitx5.addons = with pkgs; [
			fcitx5-mozc
			fcitx5-gtk
			#fcitx-configtool
			#plasma5Packages.fci5x5-qt
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
		discord
		calibre
		kicad
		krita
		# TODO: possibly switch to sddm.extraPackages if it's added
		# https://github.com/NixOS/nixpkgs/pull/242009 (nixos/sddm: enable Wayland support)
		weston
		dsview
		pulseview
		makemkv
		ffmpeg
		aegisub
		cifs-utils
		ntfs3g
		sequoia
		sioyek
		neochat
		fluffychat
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
		darling
		glibc.debug
	];
	#++ (qyriad.mkDebugForEach [
	#	#qt5.qtbase
	#	python3
	#	#kwin
	#	#plasma-workspace
	#	git
	#	curl
	#]);

	# GUI programs with NixOS modules that we can enable, instead of using environment.systemPackages.
	programs = {
		partition-manager.enable = true;
		firefox.enable = true;
		kdeconnect.enable = true;
	};

	# Used for noise suppression.
	#programs.noisetorch.enable = true;

	# Setup the terminal font we use, and make CJK render nicely.
	fonts.packages = [
		qyriad.nerdfonts
		pkgs.noto-fonts-cjk-sans
	];
	fonts.fontconfig.defaultFonts.monospace = [
		"InconsolataGo Nerd Font Mono"
	];


	# Enable reasonable default fonts for unicode and emoji.
	fonts.enableDefaultPackages = true;
}
