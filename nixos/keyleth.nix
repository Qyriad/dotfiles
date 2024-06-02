{ inputs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  services.nix-daemon.enable = true;

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "qyriad" ];
      repl-overlays = [ ../nix/../nix/repl-overlay.nix ];
    };

    registry.qyriad = {
      from = {
        id = "qyriad";
        type = "indirect";
      };
      flake = inputs.self;
    };

    nixPath = [ "nixpkgs=flake:nixpkgs" ];
  };
}
