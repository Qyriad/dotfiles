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
			lix = prev.lix.overrideAttrs {
				doInstallCheck = false;
				patches = [
					./pkgs/lix-nix-build-short-no-link.patch
				];
			};
		};
	in lib.mkAfter [
		patchLixOverlay
	];

	nix = {
		settings = {
			experimental-features = [
				"nix-command"
				"flakes"
				"pipe-operator"
				"lix-custom-sub-commands"
				#"impure-derivations"
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
			show-trace = true;

			auto-allocate-uids = pkgs.stdenv.hostPlatform.isLinux;

			sandbox = "relaxed";

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
		moor
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
		nix-tree
		nix-btm
		nix-info
		nix-query-tree-viewer
		nix-top
		#nix-visualize
		qyriad.niz
		qyriad.pzl
		#qyriad.xil
		bat
		guesswidth # column -t but smarter
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
		dogdns
		doggo
		magic-wormhole
		age
		asciinema
		ranger
		nix-output-monitor
		qyriad.git-point
		git-branchless
		openssl
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
		# OSC52 tool. Mostly for debugging.
		osc
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
		sacad # Download album covers
		trippy # Network diagnostic tool
		carl # Calendar
		dolt # "Git for data"
	] ++ config.fonts.packages; # I want font stuff to also be in /run/current-system please.
}
