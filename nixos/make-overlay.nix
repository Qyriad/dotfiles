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

		# Nice one, T-libs-api.
		# https://github.com/rust-lang/rust/issues/127343
		silicon = let
			src = final.fetchFromGitHub {
				owner = "Aloxaf";
				repo = "silicon";
				rev = "ec433c460a8ce392f2537da118153b8b13155c73";
				hash = "sha256-tKJdK+A5LJAYNC5ucW/B/3XHn9cNe81Hm2BEFdTqK+c=";
			};
		in prev.silicon.overrideAttrs (prev: {
			inherit src;
			cargoDeps = final.rustPlatform.fetchCargoTarball {
				inherit src;
				hash = "sha256-b5qgHX/SeQl/d7//MVagpTJthDcbwbM9QRoPeYEzsQs=";
			};
		});

		# Nice one, T-libs-api.
		# https://github.com/rust-lang/rust/issues/127343
		cargo-clone = let
			src = final.fetchFromGitHub {
				owner = "Qyriad";
				repo = "cargo-clone";
				rev = "refs/heads/master";
				hash = "sha256-FZHBWMV3QyydWiQP/A8+H3nizPk/MsPBaRgrQTyPqGs";
			};
		in prev.cargo-clone.overrideAttrs {
			inherit src;
			cargoDeps = final.rustPlatform.fetchCargoTarball {
				inherit src;
				hash = "sha256-LJkNywgiqcKqZN30Wla0soup3uUUo/f/Xxu0gx5Skzg=";
			};
		};

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

		# Nice one, T-libs-api.
		# https://github.com/rust-lang/rust/issues/127343
		fcp = let
			src = final.fetchFromGitHub {
				owner = "Qyriad";
				repo = "fcp";
				rev = "refs/heads/master";
				hash = "sha256-unl+4VrrJLs6UHI32zmlaM+hzNIvPohO2Q+BXFFb7U8=";
			};
		in prev.fcp.overrideAttrs {
			inherit src;
			cargoDeps = final.rustPlatform.fetchCargoTarball {
				inherit src;
				hash = "sha256-MHQ+XZq4vbiTcLcuVAjLmOaaZwStQYtgUmRoHeHIju8=";
			};
		};
	};

in overlay
