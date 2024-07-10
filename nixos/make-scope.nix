# vim: tabstop=4 shiftwidth=0 noexpandtab
{
	pkgs,
	lib,
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

in lib.makeScope pkgs.newScope (self: {
	inherit xonsh-source;
	xonsh = self.callPackage ./pkgs/xonsh { };

	inherit (qyriad-nur')
		strace-process-tree
		strace-with-colors
		cinny
		python-pipe
		xontrib-abbrevs
		xonsh-direnv
	;

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

	qlib = import ./qlib.nix { inherit lib; };
})
