{
	lib,
	stdenvNoCC,
	glibcLocales,
	linkFarm,
	dictDBCollector,
}: let
	stdenv = stdenvNoCC;
in stdenv.mkDerivation (finalAttrs:
	let self = finalAttrs.finalPackage;
in {
	name = "dictdbs-custom";
	strictDeps = true;
	__structuredAttrs = true;

	src = linkFarm "dictdbs-custom-source" {
		inherit (self) enNl nlEn;
	};

	collected = dictDBCollector {
		dictlist = [ self.enNl self.nlEn ]
		|> lib.map (drv: {
			name = lib.getName drv;
			filename = drv;
		});
	};

	installPhase = lib.dedent ''
		runHook preInstall

		mkdir -p "$out"
		cp --reflink=auto -r "$collected"/* "$out"

		runHook postInstall
	'';

	enNl = stdenv.mkDerivation {
		name = "dictdbs-en-nl";
		inherit (self) strictDeps __structuredAttrs;

		src = lib.fileset.toSource {
			root = ./.;
			fileset = lib.fileset.unions [
				./wikt-eng-nld.dict.dz
				./wikt-eng-nld.index
			];
		};

		nativeBuildInputs = [ glibcLocales ];

		dontConfigure = true;
		dontBuild = true;

		installPhase = lib.dedent ''
			runHook preInstall

			install -D ./wikt-eng-nld.dict.dz --target-dir="$out/share/dictd"
			install -D ./wikt-eng-nld.index --target-dir="$out/share/dictd"
			echo "en_US.UTF-8" > "$out/share/dictd/locale"

			runHook postInstall
		'';
	};

	nlEn = stdenv.mkDerivation {
		name = "dictdbs-nl-en";
		inherit (self) strictDeps __structuredAttrs nativeBuildInputs;
		src = lib.fileset.toSource {
			root = ./.;
			fileset = lib.fileset.unions [
				./wikt-nld-eng.dict.dz
				./wikt-nld-eng.index
			];
		};

		dontConfigure = true;
		dontBuild = true;

		installPhase = lib.dedent ''
			runHook preInstall

			install -D ./wikt-nld-eng.dict.dz --target-dir="$out/share/dictd"
			install -D ./wikt-nld-eng.index --target-dir="$out/share/dictd"
			echo "en_US.UTF-8" > "$out/share/dictd/locale"

			runHook postInstall
		'';
	};
})
