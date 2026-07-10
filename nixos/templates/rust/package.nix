{
	lib,
	stdlib,
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
in stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = cargoPackage.name;
	version = cargoPackage.version;

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
		mkShell' = mkShell.override { inherit stdenv; };
		# Fenix's Cargo doesn't have completions, but Nixpkgs' does.
		cargoCompletions = linkFarm "cargo-bash-completions" {
			"share/bash-completion" = cargo + "/share/bash-completion";
		};
	in mkShell' {
		pname = "${self.pname}-devshell";
		inputsFrom = [ self ];
		packages = [
			stdenv.cc
			fenixToolchain
			cargoCompletions
		];

		passthru = { inherit cargoCompletions; };
	};

	passthru.tests.clippy = self.overrideAttrs (prev: {
		pname = "${self.pname}-clippy";

		nativeCheckInputs = prev.nativeCheckInputs or [ ] ++ [
			clippy
		];

		dontConfigure = true;
		dontBuild = true;
		doCheck = true;
		dontFixup = true;
		dontInstallCheck = true;

		checkPhase = lib.dedent ''
			echo "cargoClippyPhase()"
			cargo clippy --all-targets --profile "$cargoCheckType" -- --deny warnings
		'';

		installPhase = lib.dedent ''
			touch "$out"
		'';
	});

	meta = {
		homepage = "https://github.com/Qyirad/PKGNAME";
		#description = "";
		maintainers = with lib.maintainers; [ qyriad ];
		#license = with lib.licenses; [ ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		#platforms = lib.platforms.all;
		mainProgram = "PKGNAME";
	};
})
