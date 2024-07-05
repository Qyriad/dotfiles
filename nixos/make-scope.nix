# vim: tabstop=4 shiftwidth=0 noexpandtab
{
	pkgs,
	lib,
	qyriad-nur,
	niz,
	log2compdb,
	pzl,
	git-point,
	crane ? git-point.inputs.crane,
	xil,
	xonsh-source,
}: let

	qyriad-nur' = import qyriad-nur { inherit pkgs; };
	xil' = import xil { inherit pkgs; };

in lib.makeScope pkgs.newScope (self: {
	inherit xonsh-source;
	xonsh = self.callPackage ./pkgs/xonsh { };

	inherit (qyriad-nur')
		strace-process-tree
		strace-with-colors
		cinny
		python-pipe
		xontrib-abbrevs
		xonsh-direnv
	;

	nerdfonts = self.callPackage ./pkgs/nerdfonts.nix { };

	udev-rules = self.callPackage ./udev-rules { };

	nix-helpers = self.callPackage ./pkgs/nix-helpers.nix { };

	xil = xil'.xil.withConfig {
		callPackageString = builtins.readFile ./xil-config.nix;
	};

	log2compdb = import log2compdb { inherit pkgs; };
	niz = import niz { inherit pkgs; };
	pzl = import pzl { inherit pkgs; };
	git-point = import git-point {
		inherit pkgs;
		craneLib = import crane {
			inherit pkgs;
		};
	};

	qlib = import ./qlib.nix { inherit lib; };
})
