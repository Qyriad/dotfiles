{ pkgs, lib }:

let
  rebuild-cmd = pkgs.writeShellScriptBin "rebuild" ''
    cmd="nixos-rebuild --print-build-logs --verbose --flake $HOME/.config $@"
    if [[ -z "''${SUDO_USER:-}" ]]; then
      if [[ "$@" = *"switch"* ]]; then
        cmd="$cmd --sudo --no-reexec"
      fi
    fi
    echo $cmd
    exec $cmd
  '';

  highlight-nix = pkgs.writeShellScriptBin "hlnix" ''
    exec bat -l nix --no-pager --style=plain $@
  '';

in
  pkgs.symlinkJoin {
    name = "nix-helpers";
    inherit rebuild-cmd;
    paths = [
      rebuild-cmd
      highlight-nix
    ];
  }
