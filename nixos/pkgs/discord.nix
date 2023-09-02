{ pkgs }:

#pkgs.stdenv.mkDerivation {
#  pname = "discord-system-electron";
#  version = pkgs.discord.version;
#  meta = pkgs.discord.meta;
#
#  nativeBuildInputs = [
#    pkgs.asar
#  ];
#}

pkgs.discord.overrideAttrs (finalAttrs: oldAttrs: {
}
