# vim: shiftwidth=0 tabstop=2 noexpandtab
{ pkgs, lib, config, ... }:

{
	imports = [
		./common.nix
		./dev.nix
		# FIXME: this import should probably be moved to a generic darwin.nix or something.
		./modules/darwin-nixos-compat.nix
	];

	system.stateVersion = 7;
	nixpkgs.hostPlatform = lib.mkDefault { system = "aarch64-darwin"; };

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

	# Some hardware stuffs.

	system.keyboard = {
		enableKeyMapping = true;
		remapCapsLockToEscape = true;
	};

	networking.wakeOnLan.enable = true;

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

	# GUI stuff in programs.*
	programs._1password-gui.enable = true;

	homebrew = {
		enable = true;
		casks = [
			# Karabiner Elements' extensions and services are a little awkward from nix-darwin.
			{ name = "karabiner-elements"; greedy = true; }

			{ name = "beeper"; greedy = true; }
			{ name = "signal@beta"; greedy = true; }
		];
		masApps = {
			# Safari Extensions.
			"1Password for Safari" = 1569813296;
			"Userscripts" = 1463298887;
			"Kagi for Safari" = 1622835804;
			"1Blocker: Ad Blocker" = 1365531024;
			"Noir" = 1592917505;
			"Refined GitHub" = 1519867270;
			"Consent-O-Matic" = 1606897889;
			"Amphetamine" = 937984704;
		};
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
		config.programs._1password-gui.package

		# Essential macOS addition.
		rectangle
		thaw

		# General GUI stuff.
		vesktop
	];
}
