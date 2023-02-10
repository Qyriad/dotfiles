{ config, pkgs, ... }:

{
  # General development stuffs.

  environment.systemPackages = with pkgs; [
    llvmPackages_latest.clangUseLLVM
    llvmPackages_latest.lld
    clang-tools_14
    rust-analyzer
    rustfmt
    cargo
    rustc
  ];
}
