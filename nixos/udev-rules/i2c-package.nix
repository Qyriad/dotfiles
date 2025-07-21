# vim: shiftwidth=4 tabstop=4 noexpandtab
{
	lib,
	stdenvNoCC,
	replaceVars,
	acl,
}: let
	stdenv = stdenvNoCC;
in stdenv.mkDerivation (self: {
	name = "qyriad-i2c-udev-rules";

	dontUnpack = true;

	src = replaceVars ./60-i2c.rules {
		setfacl = lib.getExe' acl "setfacl";
	};

	strictDeps = true;
	__structuredAttrs = true;

	dontConfigure = true;
	dontBuild = true;

	installPhase = ''
		runHook preInstall
		mkdir -p "$out/lib/udev/rules.d"
		cp -v "$src" "$out/lib/udev/rules.d"
		runHook postInstall
	'';

	dontFixup = true;

})
