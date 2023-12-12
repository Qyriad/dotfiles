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

  nix-print-cmd = pkgs.writeShellScriptBin "nix-print" ''
    for _i in $(seq $#); do
      niz eval --raw 'qyriad#pkgs' --apply "pkgs: pkgs.lib.generators.toPretty { allowPrettyValues = true; } ($1)"
      echo
      shift
    done
  '';

  highlight-nix = pkgs.writeShellScriptBin "hlnix" ''
    exec ${pkgs.bat}/bin/bat -l nix --no-pager --style=plain $@
  '';

in
  pkgs.symlinkJoin {
    name = "nix-helpers";
    inherit rebuild-cmd nixpkgs-cmd;
    paths = [
      rebuild-cmd
      nixpkgs-cmd
      nix-print-cmd
      highlight-nix
    ];
  }
