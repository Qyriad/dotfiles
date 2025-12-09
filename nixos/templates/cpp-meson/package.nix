{
	lib,
	clangStdenv,
	meson,
	ninja,
}: let
	stdenv = clangStdenv;
in stdenv.mkDerivation (self: {
	pname = "PROJECT_NAME";
	version = "0.0.1";

	strictDeps = true;
	__structuredAttrs = true;

	src = lib.fileset.toSource {
		root = ./.;
		fileset = lib.fileset.unions [
			./meson.build
			./src/meson.build
			./src/main.cpp
		];
	};

	nativeBuildInputs = [
		meson
		ninja
	];

	mesonBuildType = "debugoptimized";

	passthru.mkDevShell = {
		mkShell,
		clang-tools,
	}: let
		mkShell' = mkShell.override { inherit stdenv; };
	in mkShell' {
		inputsFrom = [ self.finalPackage ];
		packages = [ clang-tools ];
	};

	meta = {
		homepage = "https://github.com/Qyriad/PROJECT_NAME";
		#description = "";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		platforms = with lib.platforms; all;
		#mainProgram = "";
	};
})

