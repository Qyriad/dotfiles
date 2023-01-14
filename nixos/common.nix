# vim: shiftwidth=2 expandtab
{ config, pkgs, ... }:

let
  xonshPkg = (import ./pkgs/xonsh.nix { inherit pkgs; });
in {
  # Configuration for things related to Nix itself.
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "America/Denver";
  i18n.defaultLocale = "en_US.utf8";

  programs.xonsh = {
    enable = true;
    package = xonshPkg;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  environment.systemPackages = with pkgs; [
    alacritty
    tmux
    exa
    git
    fd
    ripgrep
    #xonshPkg
    nixos-option
    nodePackages.vim-language-server
    curl
    wget
    diskus
    moreutils
    grc
    delta
    direnv
  ];
}