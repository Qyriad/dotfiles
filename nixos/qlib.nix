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

	/** Fallable alternative to <nixpkgs> syntax.
	 * Returns the path if found, or null if not.
	*/
	tryLookupPath = lookupPath: let
		# This covers both pure evaluation mode and the path not being in nixPath.
		tried = builtins.tryEval (
			builtins.findFile builtins.nixPath lookupPath
		);
	in if tried.success then tried.value else null;

	lookupPathOr = lookupPath: fallback: let
		tried = tryLookupPath lookupPath;
	in if tried != null then tried else fallback;

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

	/** Assumes that your overrides compose in any order. Which is *probably* true. */
	mkOverrides = overrideSets: pkg: let
		folder = acc: overrider: overrideArgs: let
			overrideFn = acc.${overrider} or (throw "package ${pkg.name} does not an override method '${overrider}'");
		in overrideFn overrideArgs;
	in lib.foldlAttrs folder pkg overrideSets;

	/**
	Generate a suitable for passing to `mount -o` or the fs_mntops field of fstab entries
	from a structured representation of the options.

	Each option accepted by `mount -o`/fs_mntops is either a single keyword,
	*/
	genMountOpts =
		# `null` values are interpreted as keyword option names, like `noauto`.
		optionsAttrs: let
			keywordOrIni = name: value:
				if isNull value
				then name
				else "${name}=${toString value}"
			;
		in
			lib.pipe optionsAttrs [
				(lib.mapAttrsToList keywordOrIni)
				(lib.concatStringsSep ",")
			]
	;

	drvListByName =
		list:
			assert lib.assertMsg (lib.isList list) "drvListToAttrs passed non-list ${toString list}";
			lib.listToAttrs (lib.forEach list (drv: {
				name = drv.pname or drv.name;
				value = drv;
			}))
	;

	/** Like lib.genAttrs, but allows the name to be changed. */
	genAttrs' =
		list:
		mkPair:
		lib.listToAttrs (lib.concatMap (name: [ (mkPair name) ]) list);

	removeAttrs' = lib.flip builtins.removeAttrs;

	# TODO: map meta.license to (map (getAttr meta.license.shortName)) or something.
	cleanMeta = removeAttrs' [ "maintainers" "platforms" "license" ];

	/** Gives a nice overview of a derivation's attributes that aren't details for building
	 * said derivation.
	 */
	nonDrvAttrs = drv: let
		# name, pname, and version are included in `drvAttrs`, but they're useful.
		# And `outputs` is handy since it can subtly change a lot of behavior.
		toKeep = [ "name" "pname" "version" "outputs" ];
		inDrvAttrsToRemove = let
			initialAcc = lib.attrNames drv.drvAttrs;
			# A little counter-intuitive. We're building the list of names to remove from
			# the derivation attrset, and we want to *keep* some attrs, so we need to remove
			# the names we want to keep from the list of attrs to remove. lol.
		in lib.foldl' (acc: elemToKeep: lib.lists.remove elemToKeep acc) initialAcc toKeep;

		# These ones aren't included in `drvAttrs`, but we still want to remove them.
		allDrvAttrs = [
			"type"
			"outPath"
			"drvPath"
			"drvAttrs" # We also want to remove drvAttrs itself.
		] ++ inDrvAttrsToRemove;

	in (removeAttrs' allDrvAttrs drv) // {
		# This really is highly specific to us, but these meta attrs just take too much screen output.
		# If I want it, I'll ask for it.
		meta = cleanMeta (drv.meta or { });
	};


	/** Partial application for lambdas with formals!
	 * Why isn't this in nixpkgs lib…?
	*/
	partial = partialArgs: fn: {
		__functor = self: fnArgs: fn (fnArgs // partialArgs);
		# Hurray for lib.functionArgs using __functionArgs for functors.
		__functionArgs = removeAttrs' (lib.attrNames partialArgs) (lib.functionArgs fn);
	};


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
		nix-darwin ? lookupPathOr "nix-darwin" (fetchGit "https://github.com/LnL7/nix-darwin"),
		system ? builtins.currentSystem or null,
		configuration,
	}: import nix-darwin {
		inherit nixpkgs system configuration;
	};

	evalDarwin = {
		nix-darwin ? lookupPathOr "nix-darwin" (fetchGit "https://github.com/LnL7/nix-darwin"),
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
		nonDrvAttrs
		trimString
		partial
		nixosSystem
		evalNixos
		darwinSystem
		evalDarwin
		mkOverrides
		removeAttrs'
	;
}
