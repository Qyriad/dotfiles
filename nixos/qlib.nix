# vim: tabstop=2 shiftwidth=0 noexpandtab

# Utility functions for use in our NixOS modules.
# We have to be a little careful here because this is `recursiveUpdate`d into specialArgs.qyriad,
# which means these names can shadow packages in `qyriad`.
{
	lib ? import <nixpkgs/lib>,
}:

let

	trimString = str: let
		result = builtins.match "[[:space:]]*(.*[^[:space:]])[[:space:]]*";
	in lib.optionalString (result != null) (lib.head result);

	# This gets used in linux-gui.nix
	mkDebug = pkg: (pkg.overrideAttrs { separateDebugInfo = true; }).debug;
	mkDebugForEach = map mkDebug;

	/** This basically doesn't work yet. But its here to save our WIP state. */
	flakeInputToUrl = { type, ... } @ input: let
		mkFromGithub = { type, owner, repo, rev, ... }:
			assert type == "github";
			"https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
		mkFromGit = { type, url, rev, ... }:
			assert type == "git";
			url;

		typeMap = {
			github = mkFromGithub;
			git = mkFromGit;
		};
	in
		typeMap.${type} input;

	#getFlakeInputs = lockJson: let

	overrideStdenvForDrv = newStdenv: drv:
		newStdenv.mkDerivation (drv.overrideAttrs (self: { passthru.attrs = self; })).attrs
	;

	overrideStdenvForDerivation = newStdenv: drv: let
		prevAttrs = getAttrs drv;
	in newStdenv.mkDerivation prevAttrs;

	mkImpureNative = prev:
		overrideStdenvForDrv (prev.stdenvAdapters.impureUseNativeOptimizations prev.stdenv)
	;

	# Gets the original but evaluated arguments to mkDerivation, given a derivation created with mkDerivation.
	getAttrs =
		# A mkDerivation derivation.
		drv:
			assert lib.assertMsg (drv ? overrideAttrs) "getAttrs passed non-mkDerivation attrset ${toString drv}";
			let
				overriden = drv.overrideAttrs (prev: {
					passthru.__attrs = prev;
				});
			in
				overriden.__attrs
	;

	# Gets the original but evaluated arguments to buildPythonPackage (and friends), given a derivation
	# created with one of those functions.
	getPythonAttrs =
		# A buildPythonPackage family derivation.
		drv:
			assert lib.assertMsg (drv ? overridePythonAttrs) "getPythonAttrs passed a non-buildPythonPackage attrset ${toString drv}";
			let
				overriden = drv.overridePythonAttrs (prev: {
					passthru.__attrs = prev;
				});
			in
				overriden.__attrs
	;

	genMountOpts =
		# `null` values are interpreted as singleton option names, like `noauto`.
		optionsAttrs: let
			singletonOrIni = name: value:
				if isNull value
				then name
				else "${name}=${toString value}"
			;
		in
			lib.pipe optionsAttrs [
				(lib.mapAttrsToList singletonOrIni)
				(lib.concatStringsSep ",")
			]
	;

	drvListByName =
		list:
			assert lib.assertMsg (lib.isList list) "drvListToAttrs passed non-list ${toString list}";
			lib.listToAttrs (lib.forEach list (drv: { name = drv.pname or drv.name; value = drv; }))
	;

	/** Like lib.genAttrs, but allows the name to be changed. */
	genAttrs' =
		list:
		mkPair:
		lib.listToAttrs (lib.concatMap (name: [ (mkPair name) ]) list);

	removeAttrs' = lib.flip builtins.removeAttrs;

	cleanMeta = removeAttrs' [ "maintainers" "platforms" ];

	/** Like nixpkgs.lib.nixosSystem, but doesn't assume it's being called
	from a flake.
	*/
	nixosSystem = {
		nixpkgs ? <nixpkgs>,
		system ? builtins.currentSystem or null,
		configuration,
	}: let
		nixos = nixpkgs + "/nixos";
	in import nixos {
		inherit system configuration;
	};

	evalNixos = {
		nixpkgs ? <nixpkgs>,
		system ? builtins.currentSystem or null,
		modules,
	}: let
		nixos = nixpkgs + "/nixos";
		eval-config = nixos + "/lib/eval-config.nix";
	in import eval-config {
		inherit system modules;
	};

	/** Like nix-darwin.lib.darwinSystem, but doesn't assume it's being called
	from a flake.
	*/
	darwinSystem = {
		nixpkgs ? <nixpkgs>,
		nix-darwin ? fetchGit "https://github.com/LnL7/nix-darwin",
		system ? builtins.currentSystem or null,
		configuration,
	}: import nix-darwin {
		inherit nixpkgs system configuration;
	};

	evalDarwin = {
		nix-darwin ? fetchGit "https://github.com/LnL7/nix-darwin",
		system ? builtins.currentSystem or null,
		modules,
	}: let
		eval-config = nix-darwin + "/eval-config.nix";
	in import eval-config {
		inherit system modules;
	};


in {
	inherit
		mkDebug
		mkDebugForEach
		overrideStdenvForDrv
		mkImpureNative
		getAttrs
		getPythonAttrs
		genMountOpts
		drvListByName
		flakeInputToUrl
		genAttrs'
		cleanMeta
		trimString
		nixosSystem
		evalNixos
		darwinSystem
		evalDarwin
	;
}
