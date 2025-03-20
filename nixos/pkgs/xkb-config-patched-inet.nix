{
  lib,
  runCommandLocal,
  xkeyboard_config,
}: runCommandLocal "xkeyboard-config-patched-inet" {
  inherit (xkeyboard_config) src;

  patches = [
    ../keyboard-config.patch
  ];

  meta.description = lib.literalExpression ''
    environment.etc."xkb".source = pkgs.qyriad.xkeyboard_config-patched-inet;
  '';

} ''
  set -euo pipefail

  unpackPhase

  cd "$sourceRoot"

  patchPhase

  install -Dm0444 ./symbols/inet "$out/symbols/inet"
''
