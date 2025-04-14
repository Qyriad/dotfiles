# A general purpose grab-bag of dev shells that we symlink to ~/code/default.nix,
# so we can do things like `nix develop -f ~/code rust-stable`.
{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
  fenix ? builtins.getFlake "github:nix-community/fenix",
}: let
  fenixLib = import fenix { inherit pkgs; };
  fenixToolchain = fenixLib.latest.toolchain;

  toolchainHashes = {
    stable-1_84 = { name = "1.84"; sha256 = "sha256-vMlz0zHduoXtrlu0Kj1jEp71tYFXyymACW8L4jzrzNA="; };
    stable-1_85 = { name = "1.85"; sha256 = "sha256-Hn2uaQzRLidAWpfmRwSRdImifGUCAb9HeAqTYFXWeQk="; };
  };

  stable = fenixLib.stable;
  stable-1_84 = fenixLib.fromToolchainName toolchainHashes.stable-1_84;
  stable-1_85 = fenixLib.fromToolchainName toolchainHashes.stable-1_85;

  inherit (pkgs)
    libclang
    clangStdenv
    pkg-config
  ;

  mkShell = pkgs.mkShell.override { stdenv = clangStdenv; };

  mkRustShell = rustToolchain: mkShell {
    env.LIBCLANG_PATH = "${lib.getLib libclang}/lib";
    packages = [
      # To make sure the actual cc is in PATH before libclang which also has cc.
      clangStdenv.cc
      rustToolchain
      pkg-config
      libclang
      pkgs.cargo-show-asm
    ];
  };

  tauri = mkShell {
    env.LIBCLANG_PATH = "${lib.getLib libclang}/lib";
    packages = [
      # To make sure the actual cc is in PATH before libclang which also has cc.
      clangStdenv.cc
      fenixLib.stable.toolchain
      pkg-config
      libclang
      pkgs.cargo-show-asm
      pkgs.cargo-tauri
      pkgs.libsoup_2_4
      pkgs.nodejs
      pkgs.nodePackages.npm
      pkgs.nodePackages.typescript
      pkgs.webkitgtk
    ];
  };

  rust-nightly = mkRustShell fenixToolchain;
  rust-stable = mkRustShell fenixLib.stable.toolchain;
  rust-1_84 = mkRustShell stable-1_84.toolchain;
  rust-1_85 = mkRustShell stable-1_85.toolchain;
in {
  inherit rust-nightly rust-stable rust-1_84 rust-1_85 tauri;
}
