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
		inherit (qpkgs) lib;

		PKGNAME = import ./default.nix { inherit pkgs qpkgs; };
		extraVersions = lib.mapAttrs' (stdenvName: value: {
			name = "${stdenvName}-PKGNAME";
			inherit value;
		}) PKGNAME.byStdenv;

		devShell = import ./shell.nix { inherit pkgs qpkgs PKGNAME; };
		extraDevShells = lib.mapAttrs' (stdenvName: value: {
			name = "${stdenvName}-PKGNAME";
			inherit value;
		}) PKGNAME.byStdenv;
	in {
		packages = extraVersions // {
			default = PKGNAME;
			inherit PKGNAME;
		};

		devShells = extraDevShells // {
			default = devShell;
		};
	});
}
