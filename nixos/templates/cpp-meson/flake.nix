{
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
		flake-utils.url = "github:numtide/flake-utils";
	};

	outputs = {
		self,
		nixpkgs,
		flake-utils,
	}: flake-utils.lib.eachDefaultSystem (system: let

		pkgs = import nixpkgs { inherit system; };

		PROJECT_NAME = import ./default.nix { inherit pkgs; };

	in {
		packages = {
			default = PROJECT_NAME;
			inherit PROJECT_NAME;
		};

		devShells.default = pkgs.callPackage PROJECT_NAME.mkDevShell { };

		checks = {
			package = self.packages.${system}.git-point;
			devShell = self.devShells.${system}.default;
		};
	}); # outputs
}
