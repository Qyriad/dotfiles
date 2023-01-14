# vim: shiftwidth=2 expandtab

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, }:
  rec {
    nixosConfigurations.futaba = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./nixos/futaba.nix
      ];
    };
    nixosConfigurations.Futaba = nixosConfigurations.futaba;
  };
}
