{ config, pkgs, lib, modulesPath, ... }:

{
	imports = [
		./hardware.nix
		../common.nix
		../linux.nix
		../linux-gui.nix
		../dev.nix
		../resources.nix
		../mount-shizue.nix
		../modules/mount-usr.nix
		./elgato.nix
		(modulesPath + "/installer/scan/not-detected.nix")
	];

	nixpkgs.config.permittedInsecurePackages = [
		"ventoy-qt5-1.1.07"
		"olm-3.2.16"
	];
	programs.nix-ld = {
		enable = true;
		libraries = with pkgs; [
			# List by default
			zlib
			zstd
			stdenv.cc.cc
			curl
			openssl
			attr
			libssh
			bzip2
			libxml2
			acl
			libsodium
			util-linux
			xz
			systemd

			# My own additions
			libxcomposite
			libxtst
			libxrandr
			libxext
			libx11
			libxfixes
			libGL
			libva
			pipewire
			libxcb
			libxdamage
			libxshmfence
			libxxf86vm
			libelf

			# Required
			glib
			gtk2

			# Inspired by steam
			# https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/st/steam/package.nix#L36-L85
			networkmanager
			vulkan-loader
			libgbm
			libdrm
			libxcrypt
			coreutils
			pciutils
			zenity
			# glibc_multi.bin # Seems to cause issue in ARM

			# # Without these it silently fails
			libxinerama
			libxcursor
			libxrender
			libxscrnsaver
			libxi
			libsm
			libice
			gnome2.GConf
			nspr
			nss
			cups
			libcap
			SDL2
			libusb1
			dbus-glib
			ffmpeg
			# Only libraries are needed from those two
			libudev0-shim

			# needed to run unity
			gtk3
			icu
			libnotify
			gsettings-desktop-schemas
			# https://github.com/NixOS/nixpkgs/issues/72282
			# https://github.com/NixOS/nixpkgs/blob/2e87260fafdd3d18aa1719246fd704b35e55b0f2/pkgs/applications/misc/joplin-desktop/default.nix#L16
			# log in /home/leo/.config/unity3d/Editor.log
			# it will segfault when opening files if you don’t do:
			# export XDG_DATA_DIRS=/nix/store/0nfsywbk0qml4faa7sk3sdfmbd85b7ra-gsettings-desktop-schemas-43.0/share/gsettings-schemas/gsettings-desktop-schemas-43.0:/nix/store/rkscn1raa3x850zq7jp9q3j5ghcf6zi2-gtk+3-3.24.35/share/gsettings-schemas/gtk+3-3.24.35/:$XDG_DATA_DIRS
			# other issue: (Unity:377230): GLib-GIO-CRITICAL **: 21:09:04.706: g_dbus_proxy_call_sync_internal: assertion 'G_IS_DBUS_PROXY (proxy)' failed

			# Verified games requirements
			libxt
			libxmu
			libogg
			libvorbis
			SDL
			SDL2_image
			glew110
			libidn
			tbb

			# Other things from runtime
			flac
			freeglut
			libjpeg
			libpng
			libpng12
			libsamplerate
			libmikmod
			libtheora
			libtiff
			pixman
			speex
			SDL_image
			SDL_ttf
			SDL_mixer
			SDL2_ttf
			SDL2_mixer
			libappindicator-gtk2
			libdbusmenu-gtk2
			libindicator-gtk2
			libcaca
			libcanberra
			libgcrypt
			libvpx
			librsvg
			libxft
			libvdpau
			# ...
			# Some more libraries that I needed to run programs
			pango
			cairo
			atk
			gdk-pixbuf
			fontconfig
			freetype
			dbus
			alsa-lib
			expat
			# for blender
			libxkbcommon

			libxcrypt-legacy # For natron
			libGLU # For natron

			# Appimages need fuse, e.g. https://musescore.org/fr/download/musescore-x86_64.AppImage
			fuse
			e2fsprogs
		];
	};

	nixpkgs.overlays = let
		kwin-useractions-no-overflow = pkgsFinal: pkgsPrev: {
			kdePackages = pkgsPrev.kdePackages.overrideScope (kdeFinal: kdePrev: {
				# Oh boy.
				# Ripples to:
				# - plasma-workspace
				# - plasma-desktop
				# - plasma-pa
				# - xdg-desktop-portal-kde
				# - kwin-x11
				# - plasma-browser-integration
				# - powerdevil
				# - kinfocenter
				# - kdeplasma-addons
				# - firefox (wrapper, thankfully)
				kwin = kdePrev.kwin.overrideAttrs (pkgFinal: pkgPrev: {
					nativeBuildInputs = pkgPrev.nativeBuildInputs or [ ] ++ [
						kdeFinal.extra-cmake-modules
					];
					patches = pkgPrev.patches or [ ] ++ [
						# This patch inlines the "More Actions" submenu, in the menu that you
						# get from right-clicking on a window's title bar.
						./../pkgs/kwin-useractions-no-overflow.patch
					];
				});

				# Ripples to:
				kdeconnect-kde = kdePrev.kdeconnect-kde.overrideAttrs (pkgFinal: pkgPrev: {
					cmakeFlags = pkgPrev.cmakeFlags or [ ] ++ [
						"-DBLUETOOTH_ENABLED=OFF"
					];
				});
			});
		};
	in [
		kwin-useractions-no-overflow
	];

	fileSystems."/media/data" = {
		device = "/dev/disk/by-label/YukiExtdata";
		fsType = "ext4";
		options = [ "discard" "nofail" ];
	};

	system.mount-usr.enable = true;

	systemd.user = {
		services.speech-dispatcher.unitConfig = {
			StopWhenUnneeded = true;
		};
		# sockets.dbus-monitor-pcap = {
		# 	unitConfig.ConditionPathExists = "%t/bus";
		# 	socketConfig.ListenFIFO = "%t/bus.pcap";
		# 	wantedBy = [ "sockets.target" ];
		# };
		# services.dbus-monitor-pcap = {
		# 	unitConfig.ConditionPathExists = [
		# 		"%t/bus"
		# 		"/run/current-system/sw/bin/dbus-monitor"
		# 	];
		# 	serviceConfig = {
		# 		Type = "simple";
		# 		ExecStart = "/run/current-system/sw/bin/dbus-monitor --session --pcap";
		# 		Sockets = config.systemd.user.sockets.dbus-monitor-pcap.name;
		# 		StandardOutput = "fd:${config.systemd.user.sockets.dbus-monitor-pcap.name}";
		# 	};
		# };
	};

	networking.hostName = "Yuki";

	networking.useNetworkd = true;

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

	services.printing.enable = lib.mkForce false;

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

	boot.loader.systemd-boot.consoleMode = "max";

	systemd.sleep.settings.Sleep.HibernateDelaySec = "30m";

	# omg this hack seems no longer needed?
	#systemd.services."meow" = {
	#	after = [ "suspend.target" ];
	#	wantedBy = [ "suspend.target" ];
	#	script = lib.dedent ''
	#		sleep 10
	#		echo 1 | tee /sys/class/leds/*::capslock/brightness
	#		${lib.getExe' pkgs.acl "setfacl"} -m 'u:qyriad:rw' /dev/uinput
	#		${lib.getExe pkgs.sudo} -u qyriad ${lib.getExe pkgs.qyriad.unfuck-seat}
	#	'';
	#};

	#systemd.coredump.extraConfig = "MaxUse=1";

	environment.etc."modprobe.d/snd_virmidi.conf".text = lib.dedent ''
		options snd_virmidi midi_devs=1
	'';

	environment.etc."modprobe.d/v4l2loopback.conf".text = lib.dedent ''
		options v4l2loopback video_nr=10,11,12 card_label=Virt0,Virt1,Virt2 exclusive_caps=1,1,1
	'';

	environment.enableDebugInfo = true;
	environment.extraOutputsToInstall = [
		# Apparently this is how to get dig in our system path.
		"dnsutils"
	];

	systemd.network = {
		enable = true;
		# We're using NetworkManager.
		wait-online.enable = false;
		#netdevs."30-virt" = {
		#	netdevConfig.Name = "br13";
		#	netdevConfig.Kind = "bridge";
		#};
		#networks."30-virt" = {
		#	matchConfig.Name = "br13";
		#	networkConfig = {
		#		DHCP = "yes";
		#	};
		#};
	};

	boot.enableContainers = true;
	programs.extra-container.enable = true;

	programs.firefox.autoConfig = lib.readFile pkgs.qyriad.fx-autoconfig;

	containers.hass = {
		autoStart = false;
		config = { ... }: {
			imports = [ ../container-dataovermind.nix ];
			nixpkgs.pkgs = pkgs;
			services.openssh.enable = true;
			users.users.root.openssh.authorizedKeys.keys = [
				"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDI6Tdxcbr3XSD2Ok2tUb4RJ3nOszqKklkqXUrgnFM1F cardno:26_907_287"
				"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGuURQDdkB0wJGCCZra7TD7SRB+AJw3jlimZ40qq8OLE qyriad@Yuki"
			];
			system.stateVersion = "25.05";
		};
		additionalCapabilities = [ "CAP_NET_ADMIN" ];
		privateNetwork = true;
		bindMounts."/var/lib/ha-pluralkit" = {
			hostPath = "/home/qyriad/code/ha-pluralkit";
		};
	};
	#networking.interfaces.enp93s0 = {
	#	name = "enp93s0";
	#	wakeOnLan.enable = true;
	#};

	virtualisation.waydroid.enable = true;

	services.pipewire.extraConfig.pipewire-pulse = {
		"10-min-req" = {
			"pulse.min.req" = "1024/48000";
		};
	};

	services.inputplumber = {

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

	programs.wireshark = {
		enable = true;
		package = pkgs.wireshark;
		usbmon.enable = true;
	};
	users.users.qyriad.extraGroups = [ "wireshark" ];

	programs.gpu-screen-recorder = {
		enable = true;
	};

	environment.systemPackages = with pkgs; [
		qyriad.steam-launcher-script
		config.programs.steam.package.run
		makemkv
		valgrind
		ryubing
		davinci-resolve
		blender
		perf
		obs-cmd
		odin2
		#qyriad.nvtop-yuki
		libreoffice-qt6-fresh
		anki
		beeper
		qyriad.originfox
		#jj-fzf
		qyriad.unfuck-seat
		qyriad.color-journal
		qyriad.glances
		footswitch
		syncplay
		gpu-screen-recorder-gtk
		config.programs.gpu-screen-recorder.package
		tana
		config.programs.nix-ld.package
	];

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "25.05"; # Did you read the comment?
}
