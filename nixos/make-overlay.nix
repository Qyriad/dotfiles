# vim: tabstop=4 shiftwidth=0 noexpandtab
{
	lib,
	agenix,
	qyriad-nur,
	niz,
	log2compdb,
	pzl,
	cappy,
	git-point,
	xil,
	xonsh-source,
	nil-source,
	getScope ? pkgs: import ./make-scope.nix {
		inherit
			pkgs
			lib
			agenix
			qyriad-nur
			niz
			log2compdb
			pzl
			cappy
			git-point
			xil
			xonsh-source
		;
	}, # getScope

}: let
	overlay = final: prev: let
		scope = getScope final;
		availableOnHost = lib.meta.availableOn final.stdenv.hostPlatform;

	in {
		qyriad = scope;
		inherit (final.qyriad) qlib;

		# Nil HEAD has support for pipe operator.
		nil = prev.nil.overrideAttrs {
			src = nil-source;
			cargoDeps = final.rustPlatform.importCargoLock {
				lockFile = nil-source + "/Cargo.lock";
			};
		};

		numbat = prev.numbat.overrideAttrs (prev: lib.recursiveUpdate prev {
			# It's marked as broken on Darwin but seems to work fine.
			meta.broken = false;
		});

		lnav = prev.lnav.override {
			# Nixpkgs forgot to make this dependency conditional on not-Darwin.
			gpm = lib.optionalDrvAttr (availableOnHost prev.gpm) prev.gpm;
		};
	};

in overlay
