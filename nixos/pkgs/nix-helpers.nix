{
  lib,
  stdenvNoCC,
  writeShellScriptBin,
  symlinkJoin,
}:

let
  rebuild-nixos = writeShellScriptBin "rebuild" ''
    cmd="nixos-rebuild --log-format multiline-with-logs --verbose --flake $HOME/.config $@"
    if [[ -z "''${SUDO_USER:-}" ]]; then
      if [[ "$@" = *"switch"* ]]; then
        cmd="$cmd --sudo --no-reexec"
      fi
    fi
    echo $cmd
    exec $cmd
  '';

  rebuild-darwin = writeShellScriptBin "rebuild" ''
    cmd="darwin-rebuild --log-format multiline-with-logs --verbose --flake $HOME/.config --option extra-experimental-features 'nix-command flakes pipe-operator' $@"
    echo $cmd
    exec $cmd
  '';

  rebuild-cmd =
    if stdenvNoCC.hostPlatform.isDarwin then
      rebuild-darwin
    else
      rebuild-nixos;

  highlight-nix = writeShellScriptBin "hlnix" ''
    exec bat -l nix --no-pager --style=plain $@
  '';

in symlinkJoin {
  name = "nix-helpers";
  inherit rebuild-cmd;
  paths = [
    rebuild-cmd
    highlight-nix
  ];
}
