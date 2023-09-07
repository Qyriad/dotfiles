{ pkgs, lib }:

let
  inherit (pkgs) writeShellScriptBin stdenv;
  inherit (builtins) getAttr toString;

  rebuild-cmd = pkgs.writeShellScriptBin "rebuild"
    ''
      cmd="sudo nixos-rebuild --print-build-logs --verbose $@"
      echo $cmd
      exec $cmd
    '';

  nixpkgs-cmd = pkgs.writeShellScriptBin "nixpkgs"
    ''
      echo $(nix eval --impure --expr "<nixpkgs>")
    '';
in
  pkgs.symlinkJoin {
    name = "nix-helpers";
    paths = [
      rebuild-cmd
      nixpkgs-cmd
    ];
  }
