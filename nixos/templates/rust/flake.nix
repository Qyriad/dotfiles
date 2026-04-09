{
	inputs = {
		nixpkgs = {
			url = "github:NixOS/nixpkgs/nixpkgs-unstable";
			flake = false;
		};
		flake-utils.url = "github:numtide/flake-utils";
		fenix = {
			url = "github:nix-community/fenix";
			flake = false;
		};
		qyriad-nur = {
			url = "github:Qyriad/nur-packages";
			flake = false;
		};
	};

	outputs = {
		self,
		nixpkgs,
		flake-utils,
		fenix,
		qyriad-nur,
	}: flake-utils.lib.eachDefaultSystem (system: let
		pkgs = import nixpkgs { inherit system; config.checkMeta = true; };
		qpkgs = import qyriad-nur { inherit pkgs; };
		inherit (qpkgs) lib;
		fenixLib = import fenix { inherit pkgs; };

		PKGNAME = import ./default.nix { inherit pkgs qpkgs; };
		extraVersions = lib.mapAttrs' (stdenvName: value: {
			name = "${stdenvName}-PKGNAME";
			inherit value;
		}) PKGNAME.byStdenv;

		devShell = import ./shell.nix { inherit pkgs qpkgs fenixLib PKGNAME; };
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
