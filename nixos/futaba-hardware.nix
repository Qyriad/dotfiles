# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, pkgs, lib, ... }:

{
	# NixOS-generated hardware configuration for Futaba.
	boot.initrd.availableKernelModules = [
		"xhci_pci"
		"nvme"
		"usb_storage"
		"sd_mod"
		"rtsx_pci_sdmmc"
	];
	boot.initrd.kernelModules = [ ];
	boot.kernelModules = [
		"kvm-intel"
	];
	boot.extraModulePackages = [ ];

	fileSystems = {

		# Root partition.
		"/" = {
			device = "/dev/disk/by-uuid/d3743acb-48f3-4fa7-9fce-963821c5608a";
			fsType = "ext4";
		};

		# ESP.
		"/boot/efi" = {
			device = "/dev/disk/by-uuid/43B8-20F3";
			fsType = "vfat";
		};

	};
	swapDevices = [ ];

	# Enables DHCP on each ethernet and wireless interface. In case of scripted networking
	# (the default) this is the recommended approach. When using systemd-networkd it's
	# still possible to use this option, but it's recommended to use it in conjunction
	# with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
	networking.useDHCP = lib.mkDefault true;
	# networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;

	powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
	hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
