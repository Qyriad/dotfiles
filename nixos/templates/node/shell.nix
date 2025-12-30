{
	pkgs ? import <nixpkgs> { },
	qyriad-nur ? "github:Qyriad/nur-packages" |> builtins.parseFlakeRef |> builtins.fetchTree,
	qpkgs ? import qyriad-nur { inherit pkgs; },
	lib ? qpkgs.lib,
	PACKAGENAME ? qpkgs.callPackage ./package.nix { },
}: pkgs.mkShellNoCC {
	name = "devShell-${PACKAGENAME.name}";
	inputsFrom = [ PACKAGENAME ];
	packages = with pkgs; [
		typescript-go
	];

	env.DEVSHELL_SETUP = pkgs.writeShellScript "devShell-setup-${PACKAGENAME.name}" <| lib.dedent ''
		export PATH="$PWD/node_modules/.bin:$PATH"
	'';
}
