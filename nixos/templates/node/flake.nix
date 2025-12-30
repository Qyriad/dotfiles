{
	inputs = {
		nixpkgs = {
			url = "github:NixOS/nixpkgs/nixpkgs-unstable";
			flake = false;
		};
		flake-utils.url = "github:numtide/flake-utils";
		qyriad-nur = {
			url = "github:Qyriad/nur-packages";
			flake = false;
		};
	};

	outputs = {
		self,
		nixpkgs,
		flake-utils,
		qyriad-nur,
	}: flake-utils.lib.eachDefaultSystem (system: let

		pkgs = import nixpkgs { inherit system; };
		qpkgs = import qyriad-nur { inherit pkgs; };

		PACKAGENAME = import ./default.nix { inherit pkgs qpkgs; };
		devShell = import ./shell.nix { inherit pkgs qpkgs PACKAGENAME; };

	in {
		packages = {
			default = PACKAGENAME;
			inherit PACKAGENAME;
		};
		devShells.default = devShell;
	});
}
