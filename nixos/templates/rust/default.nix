# Unlocked version. For locked inputs, use the flake.
{
	pkgs ? import <nixpkgs> { },
	craneLib ? let
		crane = fetchGit {
			url = "https://github.com/ipetkov/crane";
		};
	in import crane { inherit pkgs; },
}:

{
	some-pkg = pkgs.callPackage ./package.nix {
		inherit craneLib;
	};
}
