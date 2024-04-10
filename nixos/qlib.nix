# vim: tabstop=4 shiftwidth=4 noexpandtab

# Utility functions for use in our NixOS modules.
# We have to be a little careful here because this is `recursiveUpdate`d into specialArgs.qyriad,
# which means these names can shadow packages in `qyriad`.
{
	lib,
}:

let
	# This gets used in linux-gui.nix
	mkDebug = pkg: (pkg.overrideAttrs { separateDebugInfo = true; }).debug;
	mkDebugForEach = map mkDebug;

	overrideStdenvForDrv = newStdenv: drv:
		newStdenv.mkDerivation (drv.overrideAttrs (self: { passthru.attrs = self; })).attrs
	;

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
	;
}
