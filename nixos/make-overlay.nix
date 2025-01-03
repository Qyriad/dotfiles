# vim: tabstop=4 shiftwidth=0 noexpandtab
{
	lib,
	agenix,
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
			agenix
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

		# Nice one, T-libs-api.
		# https://github.com/rust-lang/rust/issues/127343
		cargo-info = let
			src = final.fetchFromGitHub {
				owner = "Qyriad";
				repo = "cargo-info";
				rev = "refs/heads/main";
				hash = "sha256-kntuacWov8oVoUOVP3M3LhqaNsSB4OY9Jtav9886r+M=";
			};
		in prev.cargo-info.overrideAttrs {
			inherit src;
			cargoDeps = final.rustPlatform.fetchCargoTarball {
				inherit src;
				hash = "sha256-+BnPLSzIJbS7TIYvATiGFliAEDmScw4bPcj8ZC6RKqM=";
			};
		};
	};

in overlay
