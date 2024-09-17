# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, pkgs, ... }:

{
	# General development stuffs.

	environment.pathsToLink = [
		"/include"
	];

	environment.extraOutputsToInstall = [
		"dev"
		"info"
		"doc"
	];

	environment.systemPackages = with pkgs; [
		#llvmPackages_latest.clangUseLLVM
		#llvmPackages_latest.lld
		qyriad.log2compdb
		dprint
		just
		clang-tools_18
		pyright
		nodePackages.vim-language-server
		javascript-typescript-langserver
		nil
		nixd
		lua-language-server
		zls
		bear
		universal-ctags
		patchelf
		nix-doc
		lazygit
		#rust-analyzer
		#rustfmt
		#cargo
		cargo-limit
		cargo-info
		cargo-clone
		cargo-outdated
		cargo-edit
		#rustc
		git-gr
		git-imerge
		nix-eval-jobs
		colmena
		rr
		nixfmt-rfc-style
		nixpkgs-review
		# Broken after the Python 3.12 migration for some reason. Check back later.
		#quickemu
		gh
		gql
		shellcheck
		nodePackages.prettier
		awscli2
		pkgdiff
		ast-grep
		nmap
	];
}
