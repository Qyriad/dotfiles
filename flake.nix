# vim: shiftwidth=2 expandtab

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
      ${system}.packages = {
        xonsh = pkgs.callPackage ./nixos/pkgs/xonsh.nix { };
      };
    }
  )
  // rec {
    nixosConfigurations.futaba = nixpkgs.lib.nixosSystem {

      specialArgs.inputs = inputs;

      system = "x86_64-linux";
      modules = [
        ./nixos/futaba.nix
      ];
    };
    nixosConfigurations.Futaba = nixosConfigurations.futaba;

    nixosConfigurations.yuki = nixpkgs.lib.nixosSystem {
      specialArgs.inputs = inputs;
      specialArgs.qyriad = self.outputs."x86_64-linux";
      system = "x86_64-linux";
      modules = [
        ./nixos/yuki.nix
        nixseparatedebuginfod.nixosModules.default
      ];
    };
    nixosConfigurations.Yuki = nixosConfigurations.yuki;
  };
}
