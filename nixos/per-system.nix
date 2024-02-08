# vim: tabstop=4 shiftwidth=4 noexpandtab
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
	nonFlakeOutputs = {
		packages = {
			nerdfonts = pkgs.callPackage ./pkgs/nerdfonts.nix { };
			udev-rules = pkgs.callPackage ./udev-rules { };
			nix-helpers = pkgs.callPackage ./pkgs/nix-helpers.nix { };
			inherit xonsh;
			inherit (qyriad-nur) strace-process-tree;
		};

		# Truly dirty hack. This will let us transparently refer to overriden
		# or not overriden packages in nixpkgs, as flake.packages.foo is preferred over
		# flake.legacyPackages.foo by commands like `nix build`.
		# We also slip our additional lib functions in here, so we can use them
		# with the rest of nixpkgs.lib.
		legacyPackages = let
			lhs = inputs.nixpkgs.legacyPackages.${system};
			rhs = {
				lib = qlib;
				pkgs.lib = qlib;
			};
		in lib.recursiveUpdate lhs rhs;
	};


	# Outputs that do directly come from flake inputs.
	flakeOutputsPackages = {
		niz = import inputs.niz { inherit pkgs; };
		pzl = import inputs.pzl { inherit pkgs; };
		log2compdb = import inputs.log2compdb { inherit pkgs; };

		xil = let
			basePkg = inputs.xil.packages.${system}.default;
			callPackageString = ''
				let
					nixpkgs = builtins.getFlake "nixpkgs";
					qyriad = builtins.getFlake "qyriad";
					pkgs = import nixpkgs { };
					lib = pkgs.lib;
					scope = lib.makeScope pkgs.newScope (self: {
						qlib = qyriad.lib;
						qyriad = qyriad.packages.${system} // {
							lib = qyriad.lib;
						};
					});
				in
					target: scope.callPackage target { }
			'';

			xilWithConfig = basePkg.withConfig { inherit callPackageString; };
		in xilWithConfig;
	}; # flakeOutputsPackages

	flakeOutputs = {
		packages = flakeOutputsPackages;
	};

in lib.recursiveUpdate flakeOutputs nonFlakeOutputs
