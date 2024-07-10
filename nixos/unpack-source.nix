{
  lib,
  runCommand
}:
 let
  cleanArgs = args: builtins.removeAttrs args [ "src" "name" ];

  unpackSource = args @ {
    src,
    name ? src.name,
    ...
  }: runCommand name ({ inherit src; } // (cleanArgs args)) ''
    # Micro reimplementation of fetchzip's logic.
    unpackFile "$src"
    chmod -R +w source
    mv ./source "$out"
  '';

in lib.makeOverridable unpackSource
