{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  darwin,
}: stdenvNoCC.mkDerivation (self: {
  name = "homebrew-installer";
  src = fetchFromGitHub {
    owner = "Homebrew";
    repo = "install";
    # master as of 2024-03-08.
    rev = "aceed88a4a062e2b41dc40a7428c71309fce14c9";
    hash = "sha256-D7GHoQTOfbHR7PkyxlfKsJqpMP6q+yUOMFh3FUrWfXM=";
  };

  dontConfigure = true;
  dontBuild = true;

  propagatedBuildInputs = [
    darwin.binutils
  ]

  installPhase = ''
    mkdir -p "$out/bin"
    cp -v ./install.sh "$out/bin/homebrew-install.sh"
  '';
})
