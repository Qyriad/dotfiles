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

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/udev/rules.d
    cp -v $src/*.rules $out/lib/udev/rules.d

    runHook postInstall
  '';

  dontFixup = true;

  meta = {
    description = "Qyriad personal udev rules";
  };
}
