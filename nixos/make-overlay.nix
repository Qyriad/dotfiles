# vim: tabstop=4 shiftwidth=0 noexpandtab
{
	lib,
	agenix,
	qyriad-nur,
	niz,
	log2compdb,
	pzl,
	cappy,
	git-point,
	xil,
	xonsh-source,
	nil-source,
	tmux-source,
	originfox-source,
	getScope ? { pkgs, lib, qpkgs }: import ./make-scope.nix {
		lib = import qyriad-nur { mode = "lib"; inherit lib; };
		inherit
			pkgs
			agenix
			qpkgs
			niz
			log2compdb
			pzl
			cappy
			git-point
			xil
			xonsh-source
			originfox-source
		;
	}, # getScope

}: let
	overlay = pkgsFinal: pkgsPrev: let
		availableOnHost = lib.meta.availableOn pkgsFinal.stdenv.hostPlatform;
	in {
		qyriad = getScope {
			pkgs = pkgsFinal;
			lib = pkgsPrev.lib;
			inherit (pkgsFinal) qpkgs;
		};

		qpkgs = import qyriad-nur {
			pkgs = pkgsFinal;
			lib = pkgsPrev.lib;
		};

		inherit (pkgsFinal.qpkgs) nurLib;

		lib = import qyriad-nur {
			mode = "lib";
			inherit (pkgsPrev) lib;
		};

		qlib = pkgsFinal.qyriad.qlib;

		nix = pkgsPrev.nix.overrideAttrs (prev: {
			pname = "lix-patched";
			separateDebugInfo = false;
			dontStrip = true;
			patches = prev.patches or [ ] ++ [ ./pkgs/lix-print-cgroup-drvs.patch ];
		});

		# Nil HEAD has support for pipe operator.
		nil = (pkgsPrev.nil.override { nix = pkgsFinal.lix; }).overrideAttrs {
			src = nil-source;
			cargoDeps = pkgsFinal.rustPlatform.importCargoLock {
				lockFile = nil-source + "/Cargo.lock";
			};
		};

		lnav = pkgsPrev.lnav.override {
			# Nixpkgs forgot to make this dependency conditional on not-Darwin.
			gpm = lib.optionalDrvAttr (availableOnHost pkgsPrev.gpm) pkgsPrev.gpm;
		};

		kdePackages = pkgsPrev.kdePackages.overrideScope (kdeFinal: kdePrev: {
			# Ripples to:
			# - kdeconnect-kde
			# - plasma-pa
			#pulseaudio-qt = kdePrev.pulseaudio-qt.overrideAttrs (pkgPrev: {
			#	patches = (pkgPrev.patches or [ ]) ++ [
			#		./pkgs/pulseaudio-qt.patch
			#	];
			#});

			# Ripples to:
			# - plasma-browser-integration
			# - powerdevil
			# - plasma-desktop
			# - kdeplasma-addons
			# - plasma-pa
			#plasma-workspace = kdePrev.plasma-workspace.overrideAttrs (pkgPrev: {
			#	patches = (pkgPrev.patches or [ ]) ++ [
			#		# Give me XCB error information instead of "Got an error"
			#		./pkgs/plasma-workspace-appmenu-warning.patch
			#		# Give me information about the notification that didn't have an ID.
			#		./pkgs/plasma-workspace-notification-warning.patch
			#	];
			#
			#	buildInputs = pkgPrev.buildInputs or [ ] ++ [
			#		final.xorg.xcbutilerrors
			#	];
			#});

			# Ripples to:
			# - systemsettings
			# - kinfocenter
			# - kwin-x11
			# - plasma-browser-integration
			# - powerdevil
			# - plasma-pa
			# - plasma-desktop
			# - kdeplasma-addons
			# - firefox (wrapper)
			# This *seemed* to work until it broke a lot.
			#plasma-workspace = kdePrev.plasma-workspace.overrideAttrs (pkgPrev: {
			#	dontWrapQtApps = true;
			#});

			# Ripples to:
			systemsettings = kdePrev.systemsettings.overrideAttrs (pkgFinal: pkgPrev: let
				prevPatches = pkgPrev.patches or [ ];
			in {
				_showmodulepatch = ./pkgs/kde_systemsettings_showmodulename.patch;
				patches = if pkgPrev ? _showmodulepatch then prevPatches else prevPatches ++ [
					pkgFinal._showmodulepatch
				];
			});

			kdeconnect-kde = kdePrev.kdeconnect-kde.overrideAttrs (pkgFinal: pkgPrev: {
				postInstall = lib.trim ''
					substituteInPlace "$out/etc/xdg/autostart/org.kde.kdeconnect.daemon.desktop" \
						--replace-fail "Exec=$out/bin/kdeconnectd" "Exec=/run/wrappers/bin/kdeconnectd"
				'';
			});
		});

		# FIXME: this is a pretty weird way of overriding the final OBS...
		wrapOBS = pkgsPrev.wrapOBS.override {
			obs-studio = pkgsFinal.qpkgs.obs-studio-unwrapped;
		};

		# Our license only covers Bitwig 5.2.7.
		bitwig-studio5-unwrapped = pkgsPrev.bitwig-studio5-unwrapped.overrideAttrs (pkgFinal: pkgPrev: {
			version = "5.2.7";
			src = pkgsFinal.fetchurl {
				name = "bitwig-studio-${pkgFinal.version}.deb";
				url = "https://www.bitwig.com/dl/Bitwig%20Studio/${pkgFinal.version}/installer_linux/";
				hash = "sha256-Tyi7qYhTQ5i6fRHhrmz4yHXSdicd4P4iuF9FRKRhkMI=";
			};
		});

		# Update to 4.2.495 broke it for us.
		# And wrapAppImage is not `lib.mkOverrideable`'d, so overriding the source is a pain in the ass.
		beeper = let
			nixpkgs-beeper = pkgsFinal.fetchFromGitHub {
				owner = "NixOS";
				repo = "nixpkgs";
				# Commit before the update.
				rev = "5d361f1d1d9861315db845a33fa2ac6c77f075ef";
				hash = "sha256-5mqcNC1Cg9P6WKLHmpcdrZrJgWeu38fuUODLLcUmD8s=";
			};
		in pkgsFinal.callPackage (nixpkgs-beeper + "/pkgs/by-name/be/beeper/package.nix") { };

		vesktop = pkgsPrev.vesktop.overrideAttrs (prev: {
			desktopItems = lib.forEach prev.desktopItems (item: item.override {
				exec = lib.concatStringsSep " " [
					"vesktop"
					"--enable-features=UseOzonePlatform,WaylandWindowDecorations,WebRTCPipeWireCapturer"
					"--ozone-platform-hint=wayland"
					#"--gtk-version=4"
					"--enable-wayland-ime"
					"--wayland-text-input-version=3"
					"%U"
				];
				#exec = "vesktop --enable-features=UseOzonePlatform --ozone-platform=wayland --use-wayland-ime %U";
			});
		});

		obsidian = pkgsPrev.obsidian.overrideAttrs (prev: {
			desktopItem = prev.desktopItem.override {
				exec = lib.concatStringsSep " " [
					"obsidian"
					"--enable-features=UseOzonePlatform,WaylandWindowDecorations,WebRTCPipeWireCapturer"
					"--ozone-platform-hint=wayland"
					"--gtk-version=4"
					"--enable-wayland-ime"
					"--wayland-text-input-version=3"
					"%U"
				];
			};
		});

		grc = pkgsPrev.grc.overrideAttrs (prev: {
			permitUserSite = true;
			makeWrapperArgs = prev.makeWrapperArgs or [ ] ++ [
				"--set-default" "PYTHONUNBUFFERED" "1"
			];
		});

		# Optimize Ghostty for x86-64-v4
		#ghostty = prev.ghostty.overrideAttrs (prev: let
		#	inherit (final.stdenv) hostPlatform;
		#	zig = final.zig_0_13;
		#
		#	newZigHook = zig.hook.overrideAttrs {
		#		zig_default_flags = "-Doptimize=ReleaseFast --color off"
		#		+ lib.optionalString hostPlatform.isx86 " -Dcpu=x86_64_v4";
		#	};
		#
		#	hookName = lib.getName zig.hook;
		#
		#	withoutZigHook = lib.filter (p: lib.getName p != hookName) prev.nativeBuildInputs;
		#in {
		#	nativeBuildInputs = withoutZigHook ++ [
		#		newZigHook
		#	];
		#});
	};

in overlay
