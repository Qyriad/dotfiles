{
	lib,
	stdenvNoCC,
	makeBinaryWrapper,
	nodejs,
	pnpm_10,
	# Supporting both newer and older Nixpkgs.
	pnpmConfigHook ? pnpm_10.configHook,
	fetchPnpmDeps ? pnpm_10.fetchDeps,
}: let
	stdenv = stdenvNoCC;
	pnpm = pnpm_10;
	# Supporting both newer and older Nixpkgs.
	supportsFetcherV3 = version: lib.versionAtLeast version "10.26.0";
	packageJson = lib.importJSON ./package.json;
in stdenv.mkDerivation (self: {
	pname = packageJson.name;
	version = packageJson.version;

	src = lib.fileset.toSource {
		root = ./.;
		fileset = lib.fileset.unions [
			#./package.json
			./pnpm-lock.yaml
			./tsconfig.json
			./src
			./public
			./index.html
		];
	};

	pnpmDeps = fetchPnpmDeps {
		inherit (self) pname version src;
		inherit pnpm;
		fetcherVersion = if supportsFetcherV3 pnpm.version then (
			3
		) else (
			2
		);
		hash = if supportsFetcherV3 pnpm.version then (
			lib.fakeHash
		) else (
			lib.fakeHash
		);
	};

	nodejs = lib.getExe nodejs;

	nativeBuildInputs = [
		makeBinaryWrapper
		nodejs
		pnpm
		pnpmConfigHook
	];

	buildPhase = lib.dedent ''
		runHook preBuild
		pnpm build
		runHook postBuild
	'';

	installPhase = lib.dedent ''
		runHook preInstall
		mkdir -p "$out/bin" "$out/lib/annotate-ipa/lib"
		cp -r ./dist ./node_modules "$out/lib/annotate-ipa"
		runHook postInstall
	'';

	preFixup = lib.dedent ''
		makeWrapper "$nodejs" "$out/bin/annotate-ipa" \
			--chdir "$out/lib/annotate-ipa" \
			--set "NODE_ENV" "production" \
			--set "TSX_TSCONFIG_PATH" "$out/lib/annotate-ipa/tsconfig.json" \
			--append-flags "$out/lib/annotate-ipa/dist/index.mjs"
	'';
})
