# Unlocked inputs. For locked inputs, use the flake.
{
	pkgs ? import <nixpkgs> { },
	qyriad-nur ? "github:Qyriad/nur-packages" |> builtins.parseFlakeRef |> builtins.fetchTree,
	qpkgs ? import qyriad-nur { inherit pkgs; },
}: qpkgs.callPackage ./package.nix { }
