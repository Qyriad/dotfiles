# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, pkgs, inputs, qyriad, ... }:

let
	currentNixpkgs = pkgs.writeTextDir "share/nixpkgs" pkgs.path;
in {
	# Configuration for things related to Nix itself.
	nixpkgs.config.allowUnfree = true;
	nix = {
		settings.experimental-features = [ "nix-command" "flakes" ];
		# Let me do things like `nix shell "qyriad#xonsh"`.
		registry.qyriad = {
			from = {
				id = "qyriad";
				type = "indirect";
			};
			flake = inputs.self;
		};
	};

	time.timeZone = "America/Denver";
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

	environment.variables = {
		# For my debugging and hacking pleasure, set $NIXPKGS to the version of nixpkgs used by the current system.
		NIXPKGS = pkgs.path;
	};

	# Other packages we want available on all systems.
	environment.systemPackages = with pkgs; [
		tmux
		exa
		git
		fd
		ripgrep
		edir
		atool
		unzip
		xz
		zstd
		cpio
		rpm
		nodePackages.vim-language-server
		curl
		wget
		diskus
		moreutils
		grc
		delta
		direnv
		file
		moar
		faketty
		inxi
		hyfetch
		nodePackages.insect
		nixos-option
		qyriad.nix-helpers
		currentNixpkgs
		any-nix-shell
		nix-index
	];
}
