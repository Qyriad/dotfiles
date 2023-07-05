# vim: shiftwidth=2 expandtab

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.05";
  };

  outputs = { self, nixpkgs, } @ inputs:
  rec {
    nixosConfigurations.futaba = nixpkgs.lib.nixosSystem {

      specialArgs.inputs = inputs;

      system = "x86_64-linux";
      modules = [
        (_: {
        })
        ./nixos/futaba.nix
      ];
    };
    nixosConfigurations.Futaba = nixosConfigurations.futaba;
  };
}
