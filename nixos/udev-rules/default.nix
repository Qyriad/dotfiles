{
  lib,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "qyriad-udev-rules";
  version = "0.1.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./60-common.rules
      ./60-openocd.rules
      ./70-avermedia-symlink.rules
    ];
  };

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
