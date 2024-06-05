# vim: tabstop=4 shiftwidth=0 noexpandtab
{
	lib,
	qyriad-nur,
	niz,
	log2compdb,
	pzl,
	git-point,
	xil,
	xonsh-source,
	getScope ? pkgs: import ./make-scope.nix {
		inherit
			pkgs
			lib
			qyriad-nur
			niz
			log2compdb
			pzl
			git-point
			xil
			xonsh-source
		;
	}, # getScope

}: let
	overlay = final: prev: let
		scope = getScope final;
	in {
		qyriad = scope;
		inherit (scope) qlib;
	};

in overlay
