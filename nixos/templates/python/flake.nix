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
		inherit (pkgs) lib;

		PKGNAME = import ./default.nix { inherit pkgs qpkgs; };

		# default.nix exposes PKGNAME evaluated for multiple `pythonXPackages` sets,
		# so let's translate that to additional flake output attributes.
		extraVersions = lib.mapAttrs' (pyName: value: {
			name = "${pyName}-PKGNAME";
			inherit value;
		}) PKGNAME.byPythonVersion;

		devShell = import ./shell.nix { inherit pkgs qpkgs; };
		extraDevShells = lib.mapAttrs' (pyName: value: {
			name = "${pyName}-PKGNAME";
			inherit value;
		}) devShell.byPythonVersion;

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
