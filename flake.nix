# vim: shiftwidth=4 tabstop=4 noexpandtab

{
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/23.05";
		flake-utils.url = "github:numtide/flake-utils";
		nixseparatedebuginfod.url = "github:symphorien/nixseparatedebuginfod";
	};

	outputs = { self, nixpkgs, flake-utils, nixseparatedebuginfod } @ inputs:
	flake-utils.lib.eachDefaultSystem (system:
		let
			pkgs = import nixpkgs { inherit system; };
			qyriad = self.outputs.${system};
		in
		{
			packages = {
				xonsh = pkgs.callPackage ./nixos/pkgs/xonsh.nix { };
			};
		}
	)
	// rec {
		nixosConfigurations.futaba = nixpkgs.lib.nixosSystem rec {

			system = "x86_64-linux";
			specialArgs.inputs = inputs;
			specialArgs.qyriad = self.outputs.packages.${system};
			modules = [
				./nixos/futaba.nix
				nixseparatedebuginfod.nixosModules.default
			];
		};
		nixosConfigurations.Futaba = nixosConfigurations.futaba;

		nixosConfigurations.yuki = nixpkgs.lib.nixosSystem rec {
			system = "x86_64-linux";
			specialArgs.inputs = inputs;
			specialArgs.qyriad = self.outputs.packages.${system};
			modules = [
				./nixos/yuki.nix
				nixseparatedebuginfod.nixosModules.default
			];
		};
		nixosConfigurations.Yuki = nixosConfigurations.yuki;
	};
}
