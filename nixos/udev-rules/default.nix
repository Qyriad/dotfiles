{ stdenv }:

stdenv.mkDerivation {
  pname = "qyriad-udev-rules";
  version = "0.1.0";

  src = ./.;

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    mkdir -p $out/lib/udev/rules.d
    cp -v $src/*.rules $out/lib/udev/rules.d
  '';

  meta = {
    description = "Qyriad personal udev rules";
  };
}
