# vim: tabstop=4 shiftwidth=0 noexpandtab
{
	pkgs,
	lib,
	agenix,
	qyriad-nur ? throw "provide either qyriad-nur or qpkgs",
	qpkgs ? import qyriad-nur { inherit pkgs lib; },
	niz,
	log2compdb,
	pzl,
	cappy,
	git-point,
	xil,
	xonsh-source,
}: let

	agenix' = import agenix { inherit pkgs; };
	shellArray = name: "\${${name}[@]}";

in lib.makeScope qpkgs.newScope (self: {
	# Just like `pkgs.runCommandLocal`, but without stdenv's default hooks,
	# which do things like check man pages and patch ELFs.
	runCommandMinimal = name: attrs: text: let
		userPreHook = if attrs ? preHook then
			attrs.preHook + "\n"
		else
			"";
		attrs' = attrs // {
			__structuredAttrs = true;
			strictDeps = true;
			preHook = userPreHook + ''
				defaultNativeBuildInputs=()
			'';
		};
	in pkgs.runCommandLocal name attrs' text;

	steam-launcher-script = pkgs.writeShellScriptBin "launch-steam" ''
		export STEAM_FORCE_DESKTOPUI_SCALING=2.0
		export GDK_SCALE=2
		# Fix crackling audio in Rivals 2.
		export PULSE_LATENCY_MSEC=126
		export PIPEWIRE_LATENCY="2048/48000"

		exec /run/current-system/sw/bin/steam-run /lib/steam/bin_steam.sh "$@"
	'';

	inherit xonsh-source;
	xonsh = self.callPackage ./pkgs/xonsh { };

	inherit (agenix') agenix;

	obs-studio = pkgs.wrapOBS {
		plugins = [
			qpkgs.obs-chapter-marker-manager
		] ++ lib.attrValues {
			inherit (pkgs.obs-studio-plugins)
				input-overlay
				obs-pipewire-audio-capture
				obs-vkcapture
			;
		};
	};

	nvtop-yuki = pkgs.nvtopPackages.full.override {
		amd = true;
		nvidia = true;
	};

	mpv = pkgs.mpv.override {
		scripts = with pkgs.mpvScripts; [
			mpv-webm
			uosc
		];
	};

	udev-rules = self.callPackage ./udev-rules { };
	udev-rules-i2c = self.callPackage ./udev-rules/i2c-package.nix { };

	nix-helpers = self.callPackage ./pkgs/nix-helpers.nix { };

	xil = let
		xil' = import xil { inherit pkgs; };
		withNixpkgsLix = xil'.override {
			inherit (pkgs.lixPackageSets.stable) lix;
		};
	in withNixpkgsLix.withConfig {
		callPackageString = lib.readFile ./xil-config.nix;
	};

	log2compdb = import log2compdb { inherit pkgs; };
	niz = import niz { inherit pkgs; };
	pzl = let
		pzl' = import pzl { inherit pkgs; };
	in pzl'.overridePythonAttrs {
		pythonRelaxDeps = [
			"psutil"
		];
	};
	cappy = import cappy { inherit pkgs; };
	git-point = import git-point { inherit pkgs qpkgs; };

	#armcord = pkgs.armcord.overrideAttrs (prev: {
	#	installPhase = ''
	#		runHook preInstall
	#		mkdir -p "$out/bin"
	#		cp -R "opt" "$out"
	#		cp -R "usr/share" "$out/share"
	#		chmod -R g-w "$out"
	#
	#		# Wrap the startup command
	#		makeWrapper $out/opt/ArmCord/armcord $out/bin/armcord \
	#			"''${gappsWrapperArgs[@]}" \
	#			--prefix XDG_DATA_DIRS : "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/" \
	#			--add-flags "--ozone-platform=wayland --enable-features=WebRTCPipeWireCapturer" \
	#			--prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath prev.buildInputs}" \
	#			--suffix PATH : ${lib.makeBinPath [ pkgs.xdg-utils ]}
	#
	#		# Fix desktop link
	#		substituteInPlace $out/share/applications/armcord.desktop \
	#			--replace /opt/ArmCord/ $out/bin/
	#
	#		runHook postInstall
	#	'';
	#});

	#unpackSource = self.callPackage ./unpack-source.nix { };
	#/** Convenience shortcut for `unpackSource { inherit (drv) src; }; */
	#unpackDrvSrc = drv: self.unpackSource { inherit (drv) src; };
	#unpackSource = { url, hash ? null, ... }: fetchTarball ({
	#	inherit url;
	#} // lib.optionalAttrs (hash != null) {
	#	sha256 = hash;
	#});
	#unpackDrvSrc = drv: self.unpackSource { inherit (drv.src) url; };

	glances = pkgs.glances.overridePythonAttrs (prev: {
		propagatedBuildInputs = with pkgs.python3Packages; (prev.propagatedBuildInputs or [ ]) ++ [
			nvidia-ml-py
			pysmart-smartx
			zeroconf
		] ++ lib.optionals pkgs.stdenv.isLinux [
			batinfo
			wifi
		];
	});

	# Optimize Ghostty for x86-64-v4
	ghostty = pkgs.ghostty.overrideAttrs (prev: let
		inherit (pkgs.stdenv) hostPlatform;
		zig = pkgs.zig_0_13;

		newZigHook = zig.hook.overrideAttrs {
			zig_default_flags = "-Doptimize=ReleaseFast --color off"
			+ lib.optionalString hostPlatform.isx86 " -Dcpu=x86_64_v4";
		};

		hookName = lib.getName zig.hook;

		withoutZigHook = lib.filter (p: lib.getName p != hookName) prev.nativeBuildInputs;
	in {
		nativeBuildInputs = withoutZigHook ++ [
			newZigHook
		];
	});

	xkeyboard_config-patched-inet = self.callPackage ./pkgs/xkb-config-patched-inet.nix { };

	nix-update = pkgs.nix-update.overrideAttrs (prev: {
		patches = (prev.patches or [ ]) ++ [
			./pkgs/nix-update.patch
		];
	});

	qlib = let
		qlib = import ./qlib.nix { inherit lib; };
	in lib // qpkgs.lib // qlib;

	# The wrapped environment variables for kdePackages.khelpcenter are a bit... overkill,
	# and seem to result in duplicate entries all over the place.
	# Let's just make a version that assumes it's running under NixOS.
	nixos-khelpcenter = pkgs.kdePackages.khelpcenter.overrideAttrs (prev: {
		dontWrapQtApps = true;

		postFixup = ''
			wrapProgram "$out/bin/khelpcenter" \
				--set QT_PLUGIN_PATH '/run/current-system/sw/lib/qt-6/plugins' \
				--set NIXPKGS_QT6_QML_IMPORT_PATH '/run/current-system/sw/lib/qt-6/qml'
		'';
	});

	# binutils without "toolchain" stuff like `ld`, `ar`, etc.
	binutils-nolink = self.runCommandMinimal "binutils-nolink" {
		inherit (pkgs) binutils;
		outputs = [ "out" "man" "info" ];
		binutilsMan = lib.getMan pkgs.binutils;
		binutilsInfo = lib.getOutput "info" pkgs.binutils;
		passthru = pkgs.binutils;
		commandNames = [
			"addr2line"
			"nm"
			"objdump"
			"readelf"
			"size"
			"strings"
		];
	} (lib.trim ''
		for name in "${shellArray "commandNames"}"; do
			install -Dm655 "$binutils/bin/$name" --target-directory "$out/bin/"
		done

		cp --reflink=auto -r "$binutilsMan" "$man"
		cp --reflink=auto -r "$binutilsInfo" "$info"
	'');
})
