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

		usePython311 = pkg: let
			args = lib.functionArgs pkg.override;
			hasInterpreter = args ? python3;
			hasScope = args ? python3Packages;
			hasBuildPython3Package = args ? buildPython3Package;
		in pkg.override (lib.optionalAttrs hasInterpreter {
			python3 = final.python311;
		} // lib.optionalAttrs hasScope {
			python3Packages = final.python311Packages;
		} // lib.optionalAttrs hasBuildPython3Package {
			buildPython3Package = final.python311Packages.buildPythonPackage;
		});

	in {
		qyriad = scope;
		inherit (scope) qlib;

		# Nixpkgs changing the default to Python 3.12 broke stuff, naturally.
		kicad = usePython311 prev.kicad;
		# pkgs.magic-wormhole is a re-exported python3Packages.magic-wormhole.
		magic-wormhole = final.python311Packages.toPythonApplication final.python311Packages.magic-wormhole;
		asciinema = usePython311 prev.asciinema;
	};

in overlay
