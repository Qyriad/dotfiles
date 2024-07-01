{
	lib,
	stdenv,
	pkg-config,
	meson,
	ninja,
	cmake,
	fmt,
}: let
	inherit (stdenv) hostPlatform;
	isLinuxClang = hostPlatform.isLinux && stdenv.cc.isClang;
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
		pkg-config
		meson
		ninja
		cmake
	];

	buildInputs = [
		fmt
	];

	dontUseCmakeConfigure = true;

	mesonBuildType = "debugoptimized";
	mesonFlags = lib.optionals isLinuxClang [
		"-Db_lto=false"
	];

	passthru.mkDevShell = {
		mkShell,
		clang-tools,
	}: mkShell {
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

