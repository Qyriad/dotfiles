# vim: tabstop=4 shiftwidth=0 noexpandtab
{
	system,
	inputs, # should be flake inputs
	qlib,
}: let
	pkgs = import inputs.nixpkgs { inherit system; };
	inherit (pkgs) lib;

	qyriad-nur = import inputs.qyriad-nur { inherit pkgs; };

	xonsh = pkgs.callPackage ./pkgs/xonsh {
		inherit (qyriad-nur)
			python-pipe
			xontrib-abbrevs
			xonsh-direnv
		;
	};

	# Outputs that don't (directly) come from flakes.
	nonFlakeOutputs.packages = {
		nerdfonts = pkgs.callPackage ./pkgs/nerdfonts.nix { };
		udev-rules = pkgs.callPackage ./udev-rules { };
		nix-helpers = pkgs.callPackage ./pkgs/nix-helpers.nix { };
		inherit xonsh;
		inherit (qyriad-nur) strace-process-tree cinny;
	};

	nonFlakeOutputs.legacyPackages = let
		# Truly dirty hack. This will let us transparently refer to overriden
		# or not overriden packages in nixpkgs, as flake.packages.foo is preferred over
		# flake.legacyPackages.foo by commands like `nix build`.
		# We also slip our additional lib functions in here, so we can use them
		# with the rest of nixpkgs.lib.
		lhs = import inputs.nixpkgs { inherit system; };
		rhs = {
			lib = qlib;
			pkgs.lib = qlib;
		};
	in
		lib.recursiveUpdate lhs rhs;

	# Outputs that do directly come from flake inputs.
	flakeOutputs.packages = let
		inherit (inputs) niz pzl log2compdb git-point xil;
		baseXil = (import xil { inherit pkgs; }).xil;
	in {
		niz = import niz { inherit pkgs; };
		pzl = import pzl { inherit pkgs; };
		log2compdb = import log2compdb { inherit pkgs; };
		git-point = import git-point {
			inherit pkgs;
			craneLib = import git-point.inputs.crane { inherit pkgs; };
		};

		xil = baseXil.withConfig {
			callPackageString = builtins.readFile ./xil-config.nix;
		};

	}; # flakeOutputsPackages

in lib.recursiveUpdate flakeOutputs nonFlakeOutputs
