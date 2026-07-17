{
	lib,
	stdlib,
	stdenv,
	versionCheckHook,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "PACKAGENAME";
	version = "0.0.1";

	src = lib.fileset.toSource {
		root = ./.;
		fileset = lib.fileset.unions [
			./.
		];
	};

	versionCheckProgramArg = "--version";

	nativeBuildInputs = [
	];

	nativeInstallCheckInputs = [
		versionCheckHook
	];

	passthru.mkDevShell = {
		mkShell,
	}: let
		mkShell' = mkShell.override { inherit stdenv; };
	in mkShell' {
		name = lib.suffixName "devshell";
		inputsFrom = [ self ];
	};

	meta = {
		homepage = "https://github.com/Qyriad/PKGNAME";
		#description = "";
		maintainers = with lib.maintainers; [ qyriad ];
		#license = with lib.licenses; [ ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		#platforms = lib.platforms.all;
		mainProgram = "PKGNAME";
	};
})
