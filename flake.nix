# vim: shiftwidth=2 expandtab

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/fad51abd42ca17a60fc1d4cb9382e2d79ae31836";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, neovim-nightly-overlay, } @ inputs:
  rec {
    nixosConfigurations.futaba = nixpkgs.lib.nixosSystem {

      specialArgs.inputs = inputs;

      system = "x86_64-linux";
      modules = [
        (_: {
          nixpkgs.overlays = [ neovim-nightly-overlay.overlay ];
        })
        ./nixos/futaba.nix
      ];
    };
    nixosConfigurations.Futaba = nixosConfigurations.futaba;
  };
}
