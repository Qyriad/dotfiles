# vim: shiftwidth=4 tabstop=4 noexpandtab
{ pkgs, config, ... }:

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
		ruby
		basedpyright
		nodePackages.vim-language-server
		#javascript-typescript-langserver
		nil
		nixd
		lua-language-server
		zls
		mesonlsp
		bear
		universal-ctags
		patchelf
		nix-doc
		lazygit
		rust-analyzer
		#rustfmt
		#cargo
		cargo-limit
		#cargo-info
		cargo-clone
		cargo-outdated
		cargo-edit
		cargo-cache
		cargo-workspaces
		cargo-show-asm
		#rustc
		git-gr
		git-imerge
		nix-update
		nix-eval-jobs
		colmena
		rr
		nixfmt-rfc-style
		nixpkgs-review
		quickemu
		gh
		gql
		shellcheck
		nodePackages.prettier
		awscli2
		pkgdiff
		ast-grep
		nmap
		taplo
		oxlint
		scspell
		#autotools-language-server
		qyriad.lsptrace
	] ++ lib.optionals config.nixpkgs.hostPlatform.isLinux [
		systemd-lsp
	];
}
