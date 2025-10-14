info: final: prev:

let
self = rec {
  # Things I don't want to have to type `builtins.` before.
  inherit (builtins) attrValues attrNames getFlake parseFlakeRef flakeRefToString typeOf getEnv tryEval;

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
  fenix = getFlake "github:nix-community/fenix";
  qyriad-nur = getFlake "github:Qyriad/nur-packages";

  currentSystem = info.currentSystem;
  system = info.currentSystem;

  config = { allowUnfree = true; };

	/** HACK: `import` that ignores deprecation warnings. */
	importQuiet = let
		ESC = "";
		bt = builtins;
		isDeprecated = s: bt.match ''${ESC}\[1;35m(evaluation warning:.*deprecated).*'' s != null;
		traceNoDeprecated = msg: v: if bt.isString msg && isDeprecated msg then (
			v
		) else (
			bt.trace msg v
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
    overlays = attrValues qyriad.overlays;
    inherit config;
  };
  nixosLib = import (nixpkgs + "/nixos/lib") { inherit (pkgs) lib; };
  fenixLib = import fenix { inherit pkgs; };
  qpkgs = import qyriad-nur { inherit pkgs; };

  # `pkgs.lib` is soooooo much typing.
  inherit (pkgs) lib qlib stdenv;

  nixos = qyriad.nixosConfigurations.${HOSTNAME};
  darwin = qyriad.darwinConfigurations.${HOSTNAME};
  stagingNixos = staging.nixosConfigurations.${HOSTNAME};
  stagingDarwin = staging.darwinConfigurations.${HOSTNAME};

  # Stuff that lets me inspect the current directory easily.
  f = getFlake "git+file:${PWD}";
  flakePackages = f.packages.${currentSystem};
  local = qlib.importAutocall PWD;
  shell = qlib.importAutocall (PWD + "/shell.nix");

  t = lib.types;
};

# HACK: don't fetch the flakes for these lazily.
in builtins.seq self.lib builtins.seq self.qyriad builtins.seq self.pkgs self
