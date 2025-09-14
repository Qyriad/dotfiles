# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, pkgs, lib, modulesPath, ... }:

{
	imports = [
		./futaba-hardware.nix
		./common.nix
		./linux.nix
		./linux-gui.nix
		./dev.nix
		./resources.nix
		#./mount-shizue.nix
		(modulesPath + "/installer/scan/not-detected.nix")
	];

	package-groups.music-production.enable = false;

	networking.hostName = "Futaba";

	services.fwupd.enable = true;

	# Options from our custom NixOS module in ./resources.nix
	resources = {
		memory = 8;
		cpus = 8;
	};

	boot.tmp.useTmpfs = lib.mkForce false;

	# Non-NixOS generated hardware configuration.
	hardware.cpu.intel.updateMicrocode = true;
	hardware.bluetooth.enable = true;

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "22.05"; # Did you read the comment?
}
