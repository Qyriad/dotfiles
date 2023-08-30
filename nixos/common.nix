# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, pkgs, qyriad, ... }:

let
	currentNixpkgs = pkgs.writeTextDir "share/nixpkgs" pkgs.path;
in {
	# Configuration for things related to Nix itself.
	nixpkgs.config.allowUnfree = true;
	nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
		inxi
		hyfetch
		nodePackages.insect
		nixos-option
		(pkgs.writeShellScriptBin "rebuild"
			''
			cmd="sudo nixos-rebuild --print-build-logs --verbose $@"
			echo $cmd
			exec $cmd
			''
		)
		(pkgs.writeScriptBin "nixpkgs"
			''
				echo ${pkgs.path}
			''
		)
		currentNixpkgs
		any-nix-shell
	];
}
