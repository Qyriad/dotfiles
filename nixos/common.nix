# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, pkgs, lib, ... }:

{
	imports = [
		./modules/package-groups.nix
		./modules/modlib.nix
		./modules/keep-paths.nix
	];

	# Configuration for things related to Nix itself.
	nixpkgs.config.allowUnfree = true;
	# Commented out because I don't want them by default, but they're handy.
	#nixpkgs.config.showDerivationWarnings = [
	#	"maintainerless"
	#	"unknown-meta"
	#	"broken-outputs"
	#	"non-source"
	#];
	#nixpkgs.config.fetchedSourceNameDefault = "versioned";
	# HACK: I'm trying out this fancy new thing called "-N"
	nixpkgs.overlays = let
		patchLixOverlay = final: prev: {
			nix = prev.nix.overrideAttrs (prev: {
				doInstallCheck = false;
				patches = [
					./pkgs/lix-nix-build-short-no-link.patch
				];
			});
		};
	in [
		patchLixOverlay
	];

	nix = {
		settings = {
			experimental-features = [
				"nix-command"
				"flakes"
				"pipe-operator"
				"no-url-literals"
				"lix-custom-sub-commands"
				#"impure-derivations"
				"cgroups"
				"auto-allocate-uids"
			];

			extra-substituters = [
				"https://cache.lix.systems"
			];

			trusted-public-keys = [
				"cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
			];

			trusted-users = [
				"root"
				"qyriad"
			];

			keep-outputs = true;
			keep-derivations = true;
			show-trace = true;

			repl-overlays = [ ../nix/repl-overlay.nix ];
		};
	};

	# Default to Denver, let localtimed override it instantly when it is able to.
	#time.timeZone = lib.mkForce "America/Denver";

	programs.nix-index.enable = true;
	programs.bash.completion.enable = true;

	programs.gnupg.agent = {
		enable = true;
		enableSSHSupport = true;
	};

	# Other packages we want available on all systems.
	environment.systemPackages = with pkgs; [
		# Include xonsh's Python
		# The normal bash isn't bash-interactive lol.
		bashInteractive
		# `programs.bash.completion.enable` does not actually do this.
		# For some reason.
		config.programs.bash.completion.package
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
		ouch
		atool
		unzip
		xz
		zstd
		pv
		unrar
		cpio
		curl
		wget
		progress
		man-pages
		man-pages-posix
		stdmanpages
		xh
		diskus
		parallel-disk-usage
		moreutils
		grc
		file
		delta
		difftastic
		direnv
		moar
		faketty
		htop
		inxi
		hyfetch
		jq
		yq
		yt-dlp
		pstree
		silicon
		hyperfine
		nixos-option
		nix-prefetch
		qyriad.nix-helpers
		any-nix-shell
		nix-du
		qyriad.niz
		qyriad.pzl
		#qyriad.xil
		bat
		ncdu
		lnav
		fblog
		fx
		chars
		zenith
		git-imerge
		pinfo
		gron
		git-series
		git-revise
		p7zip
		dig
		dogdns
		doggo
		magic-wormhole
		age
		asciinema
		ranger
		nix-output-monitor
		qyriad.git-point
		git-branchless
		btop
		numbat
		dust
		gdu
		hwatch
		litecli
		fcp
		mediainfo
		qyriad.glances
		qpkgs.otree
		qpkgs.cyme
		qpkgs.sequin
		srgn
		jujutsu
		repgrep
		rink
		duf
		uni
		ansi2html
		qyriad.agenix
		qpkgs.age-plugin-openpgp-card
		abcmidi
		pastel
		jo
		spacer
		dasel
		graphviz
		dyff
		sacad
	] ++ config.fonts.packages; # I want font stuff to also be in /run/current-system please.
}
