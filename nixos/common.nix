# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, pkgs, ... }:

{
	# Configuration for things related to Nix itself.
	nixpkgs.config.allowUnfree = true;
	# Commented out because I don't want them by default, but they're handy.
	#nixpkgs.config.showDerivationWarnings = [
	#	"maintainerless"
	#	"unknown-meta"
	#	"broken-outputs"
	#	"non-source"
	#];
	nix = {
		settings = {
			experimental-features = [ "nix-command" "flakes" "pipe-operator" ];

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

			repl-overlays = [ ../nix/repl-overlay.nix ];
		};
	};

	time.timeZone = "America/Denver";

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
		qyriad.otree
		qyriad.cyme
		srgn
		jujutsu
		repgrep
	] ++ config.fonts.packages; # I want font stuff to also be in /run/current-system please.
}
