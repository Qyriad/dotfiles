# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, pkgs, inputs, qyriad, ... }:

{
	# Configuration for things related to Nix itself.
	nixpkgs.config.allowUnfree = true;
	nix = {
		settings = {
			experimental-features = [ "nix-command" "flakes" ];

			extra-substituters = [
				"https://cache.lix.systems"
			];

			trusted-public-keys = [
				"cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
			];

			trusted-users = [
				"root"
			];

			allowed-users = [
				"qyriad"
			];
		};

		#package = pkgs.nixVersions.unstable;

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

	time.timeZone = "America/Denver";

	programs.nix-index.enable = true;
	programs.bash.enableCompletion = true;

	programs.gnupg.agent = {
		enable = true;
		enableSSHSupport = true;
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
		curl
		wget
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
		qyriad.xil
		bat
		ncdu
		lnav
		fblog
		fx
		chars
		zenith
		git-imerge
		python3Packages.jsondiff
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
	];
}
