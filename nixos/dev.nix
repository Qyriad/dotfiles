# vim: shiftwidth=0 tabstop=2 noexpandtab
{ pkgs, lib, config, ... }:

{
	# General development stuffs.

	environment.pathsToLink = [
		"/include"
		"/opt"
	];

	environment.extraOutputsToInstall = [
		"dev"
		"info"
		"doc"
	];

	environment.systemPackages = with pkgs; [
		lldb
		#llvmPackages_latest.clangUseLLVM
		#llvmPackages_latest.lld
		qyriad.log2compdb
		dprint
		just
		llvmPackages.clang-tools
		ruby
		basedpyright
		vim-language-server
		#javascript-typescript-langserver
		nil
		nixd
		lua-language-server
		# Nixpkgs broke it.
		#zls
		mesonlsp
		bear
		universal-ctags
		patchelf
		nix-doc
		lazygit
		rust-analyzer
		#rustfmt
		# Cargo but *not* anything else.
		cargo
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
		nixfmt
		nixpkgs-review
		gh
		gql
		shellcheck
		prettier
		awscli2
		pkgdiff
		ast-grep
		nmap
		masscan
		taplo
		oxlint
		scspell
		autotools-language-server
		crates-lsp
		qpkgs.lsptrace
		mergiraf
		typescript-go
		# Command-line profiler.
		samply
		wasm-language-tools
		elf-info
		#qyriad.nvim-treesitter-parsers-all
		patchutils
		sslh
		caddy
	] ++ lib.optionals config.nixpkgs.hostPlatform.isLinux [
		# The Witchcraft Compiler Collection.
		wcc
		systemd-lsp
		rr
		qyriad.llvm-keg
		qyriad.gcc-keg
	];
}
