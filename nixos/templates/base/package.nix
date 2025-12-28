{
	lib,
	stdenv,
	versionCheckHook,
}: stdenv.mkDerivation (self: {
	pname = "PACKAGENAME";
	version = "0.0.1";

	strictDeps = true;
	__structuredAttrs = true;

	doCheck = true;
	doInstallCheck = true;

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
		mkShell' = mkShell.override { stdenv = stdenv; };
	in mkShell' {
		name = "${self.pname}-devshell-${self.version}";
		inputsFrom = [ self.finalPackage ];
	};

	meta = {
		mainProgram = "PKGNAME";
	};
})
