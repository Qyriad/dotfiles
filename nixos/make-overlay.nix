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
		;
	}, # getScope

}: let
	overlay = final: prev: let
		availableOnHost = lib.meta.availableOn final.stdenv.hostPlatform;
	in {
		qyriad = getScope {
			pkgs = final;
			lib = prev.lib;
			inherit (final) qpkgs;
		};

		qpkgs = import qyriad-nur {
			pkgs = final;
			lib = prev.lib;
		};

		inherit (final.qpkgs) nurLib;

		lib = import qyriad-nur {
			mode = "lib";
			inherit (prev) lib;
		};

		qlib = final.qyriad.qlib;

		# Nil HEAD has support for pipe operator.
		nil = prev.nil.overrideAttrs {
			src = nil-source;
			cargoDeps = final.rustPlatform.importCargoLock {
				lockFile = nil-source + "/Cargo.lock";
			};
		};

		tmux = prev.tmux.overrideAttrs {
			version = prev.tmux.version + ".${tmux-source.shortRev}";
			src = tmux-source;
		};

		lnav = prev.lnav.override {
			# Nixpkgs forgot to make this dependency conditional on not-Darwin.
			gpm = lib.optionalDrvAttr (availableOnHost prev.gpm) prev.gpm;
		};

		systemdgenie = prev.systemdgenie.overrideAttrs (prev: {
			cmakeFlags = prev.cmakeFlags or [ ] ++ [
				"-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
			];
		});

		kdePackages = prev.kdePackages.overrideScope (kdeFinal: kdePrev: {
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
			systemsettings = kdePrev.systemsettings.overrideAttrs (pkgPrev: {
				patches = pkgPrev.patches or [ ] ++ [
					./pkgs/kde_systemsettings_showmodulename.patch
				];
			});
		});

		# lsp-tree-sitter isn't broken anymore.
		python3 = prev.python3.override {
			packageOverrides = pyFinal: pyPrev: {
				lsp-tree-sitter = pyPrev.lsp-tree-sitter.overrideAttrs (pkgFinal: pkgPrev: {
					meta = pkgPrev.meta // {
						broken = false;
					};
				});
			};
		};

		# FIXME: this is a pretty weird way of overriding the final OBS...
		wrapOBS = prev.wrapOBS.override {
			obs-studio = final.qpkgs.obs-studio-unwrapped;
		};

		# Our license only covers Bitwig 5.2.7.
		bitwig-studio5-unwrapped = prev.bitwig-studio5-unwrapped.overrideAttrs (pkgFinal: pkgPrev: {
			version = "5.2.7";
			src = final.fetchurl {
				name = "bitwig-studio-${pkgFinal.version}.deb";
				url = "https://www.bitwig.com/dl/Bitwig%20Studio/${pkgFinal.version}/installer_linux/";
				hash = "sha256-Tyi7qYhTQ5i6fRHhrmz4yHXSdicd4P4iuF9FRKRhkMI=";
			};
		});

		vesktop = prev.vesktop.overrideAttrs (prev: {
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

		obsidian = prev.obsidian.overrideAttrs (prev: {
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

		grc = prev.grc.overrideAttrs (prev: {
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
