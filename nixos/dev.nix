# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, pkgs, ... }:

{
	# General development stuffs.

	environment.systemPackages = with pkgs; [
		#llvmPackages_latest.clangUseLLVM
		#llvmPackages_latest.lld
		clang-tools_15
		rust-analyzer
		rustfmt
		cargo
		rustc
	];
}
