# A general purpose grab-bag of dev shells that we symlink to ~/code/default.nix,
# so we can do things like `nix develop -f ~/code rust-stable`.
{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
  fenix ? builtins.getFlake "github:nix-community/fenix",
}: let
  fenixLib = import fenix { inherit pkgs; };
  fenixToolchain = fenixLib.latest.toolchain;

  ESC = "";

  extraTargets = [
    #"wasm32-unknown-unknown"
  ];

  toolchainHashes = {
    stable-1_84 = { name = "1.84"; sha256 = "sha256-vMlz0zHduoXtrlu0Kj1jEp71tYFXyymACW8L4jzrzNA="; };
    stable-1_85 = { name = "1.85"; sha256 = "sha256-Hn2uaQzRLidAWpfmRwSRdImifGUCAb9HeAqTYFXWeQk="; };
    stable-1_88 = { name = "1.88"; sha256 = "sha256-Qxt8XAuaUR2OMdKbN4u8dBJOhSHxS+uS06Wl9+flVEk="; };
  };

  mkRustToolchain = toolchainHashInfo: let
    nativeToolchain = fenixLib.fromToolchainName toolchainHashInfo;
    extraToolchains = lib.forEach extraTargets (targetName: let
      toolchainForTarget = fenixLib.targets.${targetName}.toolchainOf {
        channel = toolchainHashInfo.name;
        inherit (toolchainHashInfo) sha256;
      };
    in toolchainForTarget.toolchain);
    allToolchains = [ nativeToolchain.toolchain ] ++ extraToolchains;
  in fenixLib.combine allToolchains;

  stable-1_84 = mkRustToolchain toolchainHashes.stable-1_84;
  stable-1_85 = mkRustToolchain toolchainHashes.stable-1_85;
  stable-1_88 = mkRustToolchain toolchainHashes.stable-1_88;

  rust-pwd-toolchain = let
    pwd = builtins.getEnv "PWD";
    baseToolchain = fenixLib.fromToolchainFile {
      dir = pwd;
    };

    toolchain = fenixLib.combine [
      fenixLib.latest.rustfmt
      baseToolchain
    ];

    tracedToolchain =
      builtins.trace "${ESC}[32mfetching rust-toolchain from '${pwd}'${ESC}[0m"
      toolchain
    ;
  in builtins.trace "${ESC}[32mgot toolchain '${tracedToolchain.name}'${ESC}[0m" toolchain;

  inherit (pkgs)
    libclang
    clangStdenv
    pkg-config
    llvmPackages
  ;

  callPackageFrom = fromSet: f: fromSet.callPackage f { };

  mkShell = pkgs.mkShell.override { stdenv = clangStdenv; };

  mkRustShell = rustToolchain: mkShell {
    env.LIBCLANG_PATH = "${lib.getLib libclang}/lib";
    packages = [
      # To make sure the actual cc is in PATH before libclang which also has cc.
      clangStdenv.cc
      rustToolchain
      pkg-config
      libclang
      llvmPackages.bintools
      pkgs.cargo-show-asm
      pkgs.cargo-nextest
      pkgs.gnuplot
      pkgs.mdbook
      pkgs.mdbook-alerts
      pkgs.mdbook-mermaid
      pkgs.mdbook-katex
      pkgs.mdbook-linkcheck
    ];
  };

  #tauri = mkShell {
  #  env.LIBCLANG_PATH = "${lib.getLib libclang}/lib";
  #  packages = [
  #    # To make sure the actual cc is in PATH before libclang which also has cc.
  #    clangStdenv.cc
  #    fenixLib.stable.toolchain
  #    pkg-config
  #    libclang
  #    pkgs.cargo-show-asm
  #    pkgs.cargo-tauri
  #    pkgs.libsoup_2_4
  #    pkgs.nodejs
  #    pkgs.nodePackages.npm
  #    pkgs.nodePackages.typescript
  #    pkgs.webkitgtk_4_0
  #  ];
  #};

  rust-nightly = mkRustShell fenixToolchain;
  rust-stable = mkRustShell fenixLib.stable.toolchain;
  rust-1_84 = mkRustShell stable-1_84;
  rust-1_85 = mkRustShell stable-1_85;
  rust-1_88 = mkRustShell stable-1_88;
  rust-pwd = mkRustShell rust-pwd-toolchain;
  #rust-1_85 = mkRustShell (fenixLib.combine [ stable-1_85.toolchain wasm32-unknown-unknown.toolchain ]);

  c-cpp = mkShell {
    env.LIBCLANG_PATH = (lib.getLib libclang) + "/lib";

    packages = [
      # To make sure the actual cc is in PATH before libclang which also has cc.
      clangStdenv.cc
      pkg-config
      libclang
      pkgs.meson
      pkgs.cmake
      pkgs.kdePackages.extra-cmake-modules
      pkgs.ninja
      pkgs.automake
      pkgs.autoconf
    ];
  };

  kde = callPackageFrom pkgs.kdePackages ({
    clangStdenv,
    pkg-config,
    libclang,
    meson,
    cmake,
    ninja,
    automake,
    autoconf,
    extra-cmake-modules,
    qtbase,
    qtdeclarative,
  }: mkShell {
    env.LIBCLANG_PATH = "${lib.getLib libclang}/lib";

    packages = [
      # To make sure the actual cc is in PATH before libclang which also has cc.
      clangStdenv.cc
      pkg-config
      libclang
      pkgs.meson
      pkgs.cmake
      pkgs.ninja
      pkgs.automake
      pkgs.autoconf
      pkgs.kdePackages.extra-cmake-modules
      pkgs.kdePackages.qtbase
      pkgs.kdePackages.qtdeclarative
    ];
  });
in builtins.deepSeq [ pkgs.path fenix.outPath ] {
  inherit rust-nightly rust-stable rust-1_84 rust-1_85 rust-1_88 rust-pwd c-cpp kde;
}
