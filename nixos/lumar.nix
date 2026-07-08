# vim: shiftwidth=0 tabstop=2 noexpandtab
{ pkgs, lib, ... }:

{
	imports = [
		./common.nix
		# FIXME: this import should probably be moved to a generic darwin.nix or something.
		./modules/darwin-nixos-compat.nix
	];

	system.stateVersion = 7;

	nixpkgs.config.allowUnfree = true;

	networking.computerName = "Lumar";
	# This appears to be what fills $HOSTNAME in Xonsh.
	# If we set localHostName but not hostName,
	# then $HOSTNAME becomes "Lumar.local".
	networking.hostName = "Lumar";

	nix = {
		settings = {
			experimental-features = [
				"nix-command"
				"flakes"
				"pipe-operator"
				#"lix-custom-sub-commands"
				#"impure-derivations"
				"cgroups"
				"auto-allocate-uids"
			];
			trusted-users = [ "qyriad" ];
			repl-overlays = [ ../nix/repl-overlay.nix ];
		};

		nixPath = [ "nixpkgs=flake:nixpkgs" ];
	};

	system.primaryUser = "qyriad";
	system.defaults.CustomUserPreferences = {
		# Yes really...
		${lib.escapeShellArg "Apple Global Domain"} = {
			"AppleMenuBarVisibleInFullscreen" = "1";
		};
	};


	system.keyboard = {
		enableKeyMapping = true;
		remapCapsLockToEscape = true;
	};

	fonts.packages = with pkgs; [
		nerd-fonts.inconsolata-go
	];

	programs.bash.completion.enable = true;
	programs.zsh = {
		enable = true;
		enableCompletion = true;
		enableBashCompletion = true;
		enableGlobalCompInit = true;
	};
	programs.tmux.enable = true;

	homebrew = {
		enable = true;
		casks = [
		];
		greedyCasks = [
			# Karabiner Elements' extensions and services are a little awkward from nix-darwin.
			{ name = "karabiner-elements"; greedy = true; }
		];
	};

	environment.systemPackages = with pkgs; [
		#qyriad.xil
		neovim
		jujutsu
		qyriad.niz
		qyriad.git-point
		nixpkgs-review
		nixfmt-rfc-style
		nil
		nix-output-monitor
		nix-index
		rustup
		repgrep
		qyriad.xonsh
		#git-spice
		git-sizer
		ast-grep
		#havn
		rink
		# Broken right now.
		#harlequin
		ipatool
		jtbl
		imgp
		pipet
		sacad
		mousecape
		sloth-app

		# Core apps.
		wezterm
		_1password-gui

		# Essential macOS addition.
		rectangle
		thaw
	];
}
