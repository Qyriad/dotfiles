{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  services.nix-daemon.enable = true;

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "qyriad" ];
      repl-overlays = [ ../nix/repl-overlay.nix ];
    };

    nixPath = [ "nixpkgs=flake:nixpkgs" ];
  };

  environment.systemPackages = with pkgs; [
    qyriad.xil
    qyriad.niz
    qyriad.git-point
    nixpkgs-review
    nixfmt-rfc-style
    nil
    nix-output-monitor
    nix-index
    rustup
  ];
}
