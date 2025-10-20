# qpkgs.callPackage
{
	lib,
	stdenvNoCC,
	python3Packages,
	pythonHooks,
	argparse-manpage ? null,
}: lib.callWith' python3Packages ({
	python,
	setuptools,
}: let
	stdenv = stdenvNoCC;
	# FIXME: should this be python.stdenv?
	inherit (stdenv) hostPlatform buildPlatform;

	pyprojectToml = lib.importTOML ./pyproject.toml;
	project = pyprojectToml.project;
in stdenv.mkDerivation (self: {
	pname = "${python.pythonAttr}-${project.name}";
	version = project.version;

	strictDeps = true;
	__structuredAttrs = true;

	doCheck = true;
	doInstallCheck = true;

	src = lib.fileset.toSource {
		root = ./.;
		fileset = lib.fileset.unions [
			./pyproject.toml
			./src
		];
	};

	outputs = [ "out" "dist" ] ++ lib.optionals (argparse-manpage != null) [
		"man"
	];

	nativeBuildInputs = (pythonHooks python).asList ++ [
		setuptools
		argparse-manpage
	];

	postInstall = lib.optionalString (argparse-manpage != null) <| lib.trim ''
		argparse-manpage \
			--module PKGNAME \
			--function get_parser \
			--manual-title "General Commands Manual" \
			--project-name "${project.name}" \
			--description "${self.meta.description}" \
			--author "Qyriad <qyriad@qyriad.me>" \
			--prog PKGNAME \
			--version "$version" \
			--output "$man/share/man1/PKGNAME.1"
	'';

	postFixup = ''
		echo "wrapping Python programs in postFixup..."
		wrapPythonPrograms
		echo "done wrapping Python programs in postFixup"
	'';

	passthru.mkDevShell = {
		mkShellNoCC,
		pylint,
		uv,
	}: mkShellNoCC {
		name = "nix-shell-${self.finalPackage.name}";
		inputsFrom = [ self.finalPackage ];
		packages = [
			pylint
			uv
		];
	};

	meta = {
		homepage = "https://github.com/Qyriad/PKGNAME";
		description = "";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		platforms = lib.platforms.linux;
		# The version specified in pyproject.toml.
		#disabled = (python.pythonOlder "3.11") || python.isPyPy;
		broken = self.finalPackage.meta.disabled or false;
		isBuildPythonPackage = python.meta.platforms;
		mainProgram = "PKGNAME";
	};
}))
