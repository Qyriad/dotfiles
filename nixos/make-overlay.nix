# vim: tabstop=4 shiftwidth=0 noexpandtab
{
	lib,
	qyriad-nur,
	niz,
	log2compdb,
	pzl,
	git-point,
	xil,
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
		;
	}, # getScope

}: final: prev: let
	scope = getScope final;
in {
	qyriad = scope;
	qlib = scope.lib;
}
