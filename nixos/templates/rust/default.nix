{
	pkgs ? import <nixpkgs> { },
	qpkgs ? let
		src = fetchTree (builtins.parseFlakeRef "github:Qyriad/nur-packages");
	in import src { inherit pkgs; },
	clangStdenv ? pkgs.clangStdenv,
}: qpkgs.callPackage ./package.nix { inherit clangStdenv; }
