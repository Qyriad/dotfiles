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
	getScope ? pkgs: import ./make-scope.nix {
		inherit
			pkgs
			lib
			agenix
			qyriad-nur
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
		scope = getScope final;
		availableOnHost = lib.meta.availableOn final.stdenv.hostPlatform;

	in {
		qyriad = scope;
		inherit (final.qyriad) qlib;

		# I don't need to build aws-sdk-cpp every time, tbh.
		nix = prev.nix.override { aws-sdk-cpp = null; };

		# Nil HEAD has support for pipe operator.
		nil = prev.nil.overrideAttrs {
			src = nil-source;
			cargoDeps = final.rustPlatform.importCargoLock {
				lockFile = nil-source + "/Cargo.lock";
			};
		};

		numbat = prev.numbat.overrideAttrs (prev: lib.recursiveUpdate prev {
			# It's marked as broken on Darwin but seems to work fine.
			meta.broken = false;
		});

		lnav = prev.lnav.override {
			# Nixpkgs forgot to make this dependency conditional on not-Darwin.
			gpm = lib.optionalDrvAttr (availableOnHost prev.gpm) prev.gpm;
		};

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
			plasma-workspace = kdePrev.plasma-workspace.overrideAttrs (pkgPrev: {
				patches = (pkgPrev.patches or [ ]) ++ [
					# Give me XCB error information instead of "Got an error"
					./pkgs/plasma-workspace-appmenu-warning.patch
					# Give me information about the notification that didn't have an ID.
					./pkgs/plasma-workspace-notification-warning.patch
				];

				buildInputs = pkgPrev.buildInputs or [ ] ++ [
					final.xorg.xcbutilerrors
				];
			});
		});

		# Our license only covers Bitwig 5.2.7.
		bitwig-studio5-unwrapped = prev.bitwig-studio5-unwrapped.overrideAttrs (pkgFinal: pkgPrev: {
			version = "5.2.7";
			src = final.fetchurl {
				name = "bitwig-studio-${pkgFinal.version}.deb";
				url = "https://www.bitwig.com/dl/Bitwig%20Studio/${pkgFinal.version}/installer_linux/";
				hash = "sha256-Tyi7qYhTQ5i6fRHhrmz4yHXSdicd4P4iuF9FRKRhkMI=";
			};
		});
	};

in overlay
