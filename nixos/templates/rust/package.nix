{
	lib,
	stdenv,
	rustHooks,
	rustPlatform,
	cargo,
	clippy,
	versionCheckHook,
}: let
	cargoToml = lib.importTOML ./Cargo.toml;
	cargoPackage = cargoToml.package;

in stdenv.mkDerivation (self: {
	pname = cargoPackage.name;
	version = cargoPackage.version;

	strictDeps = true;
	__structuredAttrs = true;

	doCheck = true;
	doInstallCheck = true;

	src = lib.fileset.toSource {
		root = ./.;
		fileset = lib.fileset.unions [
			./Cargo.toml
			./Cargo.lock
			./src
		];
	};

	cargoDeps = rustPlatform.importCargoLock {
		lockFile = ./Cargo.lock;
	};

	versionCheckProgramArg = "--version";

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
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

	passthru.tests.clippy = self.finalPackage.overrideAttrs (prev: {
		pname = "${self.pname}-clippy";

		nativeCheckInputs = prev.nativeCheckInputs or [ ] ++ [
			clippy
		];

		dontConfigure = true;
		dontBuild = true;
		doCheck = true;
		dontFixup = true;
		dontInstallCheck = true;

		checkPhase = lib.trim ''
			echo "cargoClippyPhase()"
			cargo clippy --all-targets --profile "$cargoCheckType" -- --deny warnings
		'';

		installPhase = lib.trim ''
			touch "$out"
		'';
	});

	meta = {
		mainProgram = "PKGNAME";
	};
})
