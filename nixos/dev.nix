# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, pkgs, qyriad, ... }:

{
	# General development stuffs.

	environment.systemPackages = with pkgs; [
		#llvmPackages_latest.clangUseLLVM
		#llvmPackages_latest.lld
		qyriad.log2compdb
		clang-tools_15
		pyright
		rust-analyzer
		rustfmt
		cargo
		rustc
	];
}
