{ pkgs }:
pkgs.stdenv.mkDerivation {
  pname = "qyriad-udev-rules";
  meta.description = "Qyriad personal udev rules";
  version = "0.1.0";
  dontBuild = true;
  dontConfigure = true;
  src = ./.;

  installPhase = ''
    mkdir -p $out/lib/udev/rules.d
    cp -v $src/*.rules $out/lib/udev/rules.d
  '';
}
