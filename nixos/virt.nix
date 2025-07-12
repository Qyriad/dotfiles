# vim: shiftwidth=4 tabstop=4 noexpandtab
{ pkgs, ... }:

# WIP
{
	programs.virt-manager.enable = true;

	virtualisation = {
		libvirtd.enable = true;
		libvirtd.qemu.runAsRoot = false;
		libvirtd.qemu.package = pkgs.qemu_full;
	};

	#environment.systemPackages = [
	#	pkgs.qyriad.quickemu-darwin
	#];
}
