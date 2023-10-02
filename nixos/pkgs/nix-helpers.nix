{ pkgs, lib }:

let
  inherit (pkgs) writeShellScriptBin stdenv;

  rebuild-cmd = pkgs.writeShellScriptBin "rebuild" ''
      cmd="sudo nixos-rebuild --print-build-logs --verbose --flake $HOME/.config $@"
      echo $cmd
      exec $cmd
  '';

  nixpkgs-cmd = pkgs.writeShellScriptBin "nixpkgs" ''
      echo $(nix eval --impure --expr "<nixpkgs>")
  '';

  niz-cmd = pkgs.writeShellScriptBin "niz" ''
    exec nix --log-format bar-with-logs --print-build-logs --verbose $@ --command xonsh
  '';
in
  pkgs.symlinkJoin {
    name = "nix-helpers";
    inherit rebuild-cmd nixpkgs-cmd;
    paths = [
      rebuild-cmd
      nixpkgs-cmd
      niz-cmd
    ];
  }
