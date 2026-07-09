info: final: prev:

let
self = rec {
	# Things I don't want to have to type `builtins.` before.
	inherit (builtins) attrValues attrNames getFlake parseFlakeRef flakeRefToString typeOf getEnv tryEval;

	fetchFlakeRef = flakeref: flakeref |> parseFlakeRef |> fetchTree;

	# Mostly used for other stuff below,
	# but also handy in the repl if I want to avoid parentheses.
	PWD = getEnv "PWD";
	HOSTNAME = getEnv "HOSTNAME";

	# Bare flakes I use frequently enough.
	qyriad = getFlake "qyriad";
	# The version of `qyriad` that hasn't been deployed yet.
	staging = let
		dotfiles = getEnv "XDG_CONFIG_HOME";
	in getFlake ("git+file:${dotfiles}");
	nixpkgs = getFlake "nixpkgs";
	nixpkgs-master = getFlake "github:NixOS/nixpkgs/master";
	nixpkgs-unstable = getFlake "github:NixOS/nixpkgs/nixpkgs-unstable";
	nixpkgs-staging = getFlake "github:NixOS/nixpkgs/staging";
	fenix = getFlake "github:nix-community/fenix";
	crane = getFlake "github:ipetkov/crane";
	oxalica-rust = getFlake "github:oxalica/rust-overlay";
	qyriad-nur = getFlake "github:Qyriad/nur-packages";

	currentSystem = info.currentSystem;
	system = info.currentSystem;

	config = {
		allowUnfree = true;
		microsoftVisualStudioLicenseAccepted = true;
	};

	/** HACK: `import` that ignores deprecation warnings. */
	importQuiet = let
		ESC = "";
		isDeprecated = s: builtins.match ''${ESC}\[1;35m(evaluation warning:.*deprecated).*'' s != null;
		traceNoDeprecated = msg: v: if builtins.isString msg && isDeprecated msg then (
			v
		) else (
			builtins.trace msg v
		);
	in scopedImport {
		builtins = builtins // {
			trace = traceNoDeprecated;
		};
		import = importQuiet;
	};

	# Instantiated forms of those flakes.
	pkgs = importQuiet nixpkgs {
		system = info.currentSystem;
		overlays = [ qyriad.overlays.default ];
		inherit config;
	};
	pkgs-master = importQuiet nixpkgs-master {
		inherit system config;
		overlays = [ qyriad.overlays.default ];
	};
	pkgs-unstable = importQuiet nixpkgs-unstable {
		inherit system config;
		overlays = [ qyriad.overlays.default ];
	};
	pkgs-staging = importQuiet nixpkgs-staging {
		inherit system config;
		overlays = [ qyriad.overlays.default ];
	};
	nixosLib = import (nixpkgs + "/nixos/lib") { inherit (pkgs) lib; featureFlags.minimalModules = true; };
	fenixLib = import fenix { inherit pkgs; };
	craneLib = import crane { inherit pkgs; };
	qpkgs = import qyriad-nur { inherit pkgs; };

	# `pkgs.lib` is soooooo much typing.
	inherit (pkgs) lib qlib stdenv clangStdenv;
	mkShell' = pkgs.mkShell.override { stdenv = clangStdenv; };

	meta = {
		name,
		pname ? null,
		version ? null,
		passthru ? null,
		meta ? { },
		...
	}: {
		inherit name pname version;
		description = meta.description;
		homepage = meta.homepage or null;
		mainProgram = meta.mainProgram or null;
		outputsToInstall = meta.outputsToInstall or null;
		position = meta.position or null;
	}
	|> lib.filterAttrs (_: value: value != null)
	;

	pkgsMeta = pkgs
	|> lib.mapDerivationAttrsetRecursive meta;

	# Very cursed.
	pkgsSrcs = pkgs
	|> lib.mapDerivationAttrsetRecursive pkgs.srcOnly;

	# If I'm using pkgsCross, I probably want to silence unsupported system.
	pkgsCross = let
		pkgs = importQuiet nixpkgs {
			inherit system;
			overlays = [ qyriad.overlays.default ];
			config = config // {
				allowUnsupportedSystem = true;
				allowUnfree = true;
			};
		};
	in pkgs.pkgsCross;

	sumPlat = {
		config,
		linker,
		...
	}: "${config}+${linker}";

	sumStdenv = {
		buildPlatform,
		hostPlatform,
		targetPlatform,
		...
	}: {
		build = sumPlat buildPlatform;
		host = sumPlat hostPlatform;
		target = sumPlat targetPlatform;
		__toString = {
			build,
			host,
			target,
			...
		}: ''
			build:  ${build}
			host:   ${host}
			target: ${target}
		'' |> lib.dedent |> lib.trim;
	};

	ssumStdenv = {
		buildPlatform,
		hostPlatform,
		targetPlatform,
		...
	}@stdenv: toString (sumStdenv stdenv);

	nixos = qyriad.nixosConfigurations.${HOSTNAME};
	darwin = qyriad.darwinConfigurations.${HOSTNAME};
	stagingNixos = staging.nixosConfigurations.${HOSTNAME};
	stagingDarwin = staging.darwinConfigurations.${HOSTNAME};

	# Stuff that lets me inspect the current directory easily.
	f = getFlake "git+file:${PWD}";
	flakePackages = f.packages.${currentSystem};
	fpackages = f.packages.${currentSystem};
	fchecks = f.checks.${currentSystem};
	fout = f.outputs;
	fnixpkgs = f.inputs.nixpkgs;
	fpkgs = import f.inputs.nixpkgs { inherit system; };
	local = qlib.importAutocall PWD;
	l = local;
	ll = local.lib;
	shell = qlib.importAutocall (PWD + "/shell.nix");

	t = lib.types;
	/** Perform module-system type checking and resolving on a single option value. */
	inherit (lib) typeCheck;

	# Should probably move these into qyriad-nur lib or something.
	idx = index: list: builtins.elemAt list index;
	doesntThrow = v: (builtins.tryEval v).success;
	filterThrowingAttrs = lib.filterAttrs (k: v: doesntThrow v);
	call = callFrom: f: callFrom.callPackage f { };
};

# HACK: don't fetch the flakes for these lazily.
in builtins.seq self.lib builtins.seq self.qyriad builtins.seq self.pkgs self
