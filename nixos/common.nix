# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, pkgs, lib, inputs, qyriad, ... }:

{
	# Configuration for things related to Nix itself.
	nixpkgs.config.allowUnfree = true;
	nix = {
		settings.experimental-features = [ "nix-command" "flakes" ];

		package = pkgs.nixVersions.unstable;

		# Let me do things like `nix shell "qyriad#xonsh"`.
		registry.qyriad = {
			from = {
				id = "qyriad";
				type = "indirect";
			};
			flake = inputs.self;
		};
		# Pin nixpkgs.
		registry.nixpkgs = {
			from = {
				id = "nixpkgs";
				type = "indirect";
			};
			flake = inputs.nixpkgs;
		};
		nixPath = [
			"nixpkgs=flake:nixpkgs"
			"/nix/var/nix/profiles/per-user/root/channels"
		];
	};

	# On Linux, services.localtimed takes care of this.
	time.timeZone = lib.optionalString pkgs.stdenv.isLinux "America/Denver";
	i18n.defaultLocale = "en_US.utf8";

	programs.xonsh = {
		enable = true;
		package = qyriad.xonsh;
	};

	programs.git = {
		enable = true;
		lfs.enable = true;
	};

	# Add ~/.local/bin to system path.
	environment.localBinInPath = true;

	programs.nix-index.enable = true;
	# Covered by nix-index, not that its integrations support our shell.
	programs.command-not-found.enable = false;
	programs.bash.enableCompletion = true;

	documentation = {
		# Include -dev manpages
		dev.enable = true;
		# Make apropos(1) work.
		man.generateCaches = true;
		# This fails with `cannot lookup '<nixpkgs>' in pure evaluation mode.
		# TODO: debug
		#nixos.includeAllModules = true;
	};

	# Other packages we want available on all systems.
	environment.systemPackages = with pkgs; [
		# The normal bash isn't bash-interactive lol.
		bashInteractive
		tmux
		zellij
		eza
		git
		git-extras
		tig
		fd
		ripgrep
		edir
		unar
		atool
		unzip
		xz
		zstd
		unrar
		cpio
		rpm
		nodePackages.vim-language-server
		curl
		wget
		man-pages
		man-pages-posix
		stdmanpages
		xh
		diskus
		moreutils
		grc
		delta
		direnv
		file
		moar
		faketty
		htop
		inxi
		hyfetch
		nodePackages.insect
		jq
		yt-dlp
		pstree
		silicon
		hyperfine
		nixos-option
		nix-prefetch
		qyriad.nix-helpers
		any-nix-shell
		qyriad.niz
		qyriad.pzl
		qyriad.xil
		bat
		ncdu
	];
}
