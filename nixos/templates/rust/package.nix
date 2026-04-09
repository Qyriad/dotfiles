{
	lib,
	clangStdenv,
	rustHooks,
	rustPlatform,
	cargo,
	clippy,
	versionCheckHook,
}: let
  stdenv = clangStdenv;
	cargoToml = lib.importTOML ./Cargo.toml;
	cargoPackage = cargoToml.package;
in stdenv.mkDerivation (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
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
		fenixToolchain,
		linkFarm,
		cargo,
	}: let
		mkShell' = mkShell.override { stdenv = stdenv; };
		# Fenix's Cargo doesn't have completions, but Nixpkgs' does.
		cargoCompletions = linkFarm "cargo-bash-completions" {
			"share/bash-completion" = cargo + "/share/bash-completion";
		};
	in mkShell' {
		name = "${self.pname}-devshell-${self.version}";
		inputsFrom = [ self.finalPackage ];
		packages = [
			stdenv.cc
			fenixToolchain
			cargoCompletions
		];

		passthru = { inherit cargoCompletions; };
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
