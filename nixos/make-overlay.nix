# vim: tabstop=4 shiftwidth=0 noexpandtab
{
	lib,
	qyriad-nur,
	niz,
	log2compdb,
	pzl,
	git-point,
	xil,
}: let
	overlay = final: prev: let

		scope = import ./make-scope.nix {
			pkgs = final;
			inherit
				lib
				qyriad-nur
				niz
				log2compdb
				pzl
				git-point
				xil
			;
		};
	in {
		qyriad = scope;
		qlib = scope.lib;
	};

in overlay
