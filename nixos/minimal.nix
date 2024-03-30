# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, pkgs, modulesPath, ... }:

{
  imports = [
    ./common.nix
    ./linux.nix
    ./dev.nix
    ./resources.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  networking.hostName = "Yuki-aarch64";
  resources = {
    memory = 32;
    cpus = 32;
  };
}
