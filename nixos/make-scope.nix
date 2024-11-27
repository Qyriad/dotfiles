# vim: tabstop=4 shiftwidth=0 noexpandtab
{
	pkgs,
	lib,
	agenix,
	qyriad-nur,
	niz,
	log2compdb,
	pzl,
	git-point,
	crane ? git-point.inputs.crane,
	craneLib ? import crane { inherit pkgs; },
	xil,
	xonsh-source,
}: let

	qyriad-nur' = import qyriad-nur { inherit pkgs; };
	xil' = import xil { inherit pkgs; };
	agenix' = import agenix { inherit pkgs; };

in lib.makeScope pkgs.newScope (self: let
	inherit (self) qlib;
in {
	# Just like `pkgs.runCommandLocal`, but without stdenv's default hooks,
	# which do things like check man pages and patch ELFs.
	runCommandMinimal = name: attrs: text: let
		userPreHook = if attrs ? preHook then
			attrs.preHook + "\n"
		else
			"";
		attrs' = attrs // {
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

		exec /run/current-system/sw/bin/steam-run /run/current-system/sw/lib/steam/bin_steam.sh "$@"
	'';

	inherit xonsh-source;
	xonsh = self.callPackage ./pkgs/xonsh { };

	inherit (agenix') agenix;

	inherit (qyriad-nur')
		strace-process-tree
		strace-with-colors
		intentrace
		cinny
		otree
		cyme
		python-pipe
		xontrib-abbrevs
		xonsh-direnv
		obs-chapter-marker-manager
		age-plugin-openpgp-card
	;

	obs-studio = pkgs.wrapOBS {
		plugins = [
			self.obs-chapter-marker-manager
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
		];
	};

	nerdfonts = self.callPackage ./pkgs/nerdfonts.nix { };

	udev-rules = self.callPackage ./udev-rules { };

	nix-helpers = self.callPackage ./pkgs/nix-helpers.nix { };

	xil = xil'.xil.withConfig {
		callPackageString = builtins.readFile ./xil-config.nix;
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
	git-point = import git-point { inherit pkgs craneLib; };

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
			batinfo
			nvidia-ml-py
			pysmart-smartx
			wifi
			zeroconf
		];
	});

	vesktop = pkgs.vesktop.overrideAttrs (prev: {
		desktopItems = lib.forEach prev.desktopItems (item: item.override {
			exec = lib.concatStringsSep " " [
				"--enable-features=UseOzonePlatform,WaylandWindowDecorations,WebRTCPipeWireCapturer"
				"--ozone-platform-hint=wayland"
				"--gtk-version=4"
				"--enable-wayland-ime"
				"--wayland-text-input-version=3"
			];
			#exec = "vesktop --enable-features=UseOzonePlatform --ozone-platform=wayland --use-wayland-ime %U";
		});
	});

	qlib = let
		qlib = import ./qlib.nix { inherit lib; };
		# Nixpkgs lib with additions from qyriad-nur.
		nurLib = qyriad-nur'.lib;
		# The additions to lib from qyriad-nur without Nixpkgs lib.
		nurAdditions = qlib.removeAttrs' (lib.attrNames lib) nurLib;
		qlibWithAdditions = nurAdditions // qlib;
		# And then finally we'll force the result. Nothing here should be recursive or fail evaluation.
	in qlib.force qlibWithAdditions;
})
