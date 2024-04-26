# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, pkgs, qyriad, ... }:

{
	# General development stuffs.

	environment.systemPackages = with pkgs; [
		#llvmPackages_latest.clangUseLLVM
		#llvmPackages_latest.lld
		qyriad.log2compdb
		dprint
		just
		clang-tools_18
		pyright
		nodePackages.vim-language-server
		nil
		lua-language-server
		bear
		universal-ctags
		nix-doc
		lazygit
		#rust-analyzer
		#rustfmt
		#cargo
		#rustc
		git-gr
	];
}
