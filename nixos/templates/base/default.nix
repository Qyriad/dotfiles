# Unlocked inputs. For locked inputs, use the flake.
{
	pkgs ? import <nixpkgs> { },
	qpkgs ? let
		src = fetchTree (builtins.parseFlakeRef "github:Qyriad/nur-packages");
	in import src { inherit pkgs; },
}: qpkgs.callPackage ./package.nix { }
