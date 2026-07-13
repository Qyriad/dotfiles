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
	system.defaults.NSGlobalDomain = {
		"AppleShowAllExtensions" = true;

		# Expand save panels by default.
		"NSNavPanelExpandedStateForSaveMode" = true;
		"NSNavPanelExpandedStateForSaveMode2" = true;
	};
	system.defaults.finder = {
		# --group-directories-first our beloved.
		"_FXSortFoldersFirst" = true;
		# Not sure if this is any different from the one in NSGlobalDomain.
		"AppleShowAllExtensions" = true;
		# List view.
		"FXPreferredViewStyle" = "Nlsv";
		# Show path breadcrumbs at the bottom.
		"ShowPathbar" = true;
		"ShowStatusBar" = true;
		# Resize columns to fit filenames.
		"_FXEnableColumnAutoSizing" = true;
	};
	system.defaults.screencapture = {
		"location" = "~/Pictures/Screenshots";
	};
	system.defaults.trackpad = {
		# System Preferences -> Trackpad -> Tap to click.
		# Is this any different from system.defaults.NSGlobalDomain."com.apple.mouse.tapBehavior"?
		"Clicking" = true;
	};
	system.defaults.CustomUserPreferences = {
		# Yes really...
		${lib.escapeShellArg "Apple Global Domain"} = {
			"AppleMenuBarVisibleInFullscreen" = "1";
		};

		"com.apple.Safari" = {
			# View -> Show Status Bar.
			"ShowOverlayStatusBar" = true;
		};

		"com.apple.dock" = {
			# System Preferences -> Desktop & Dock ->
			# Automatically rearrange Spaces based on most recent use.
			"mru-spaces" = false;
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

	# Does rely on the ~/.gnupg directory existing in some way.
	programs.gnupg.agent = {
		enable = true;
		enableSSHSupport = true;
	};

	# GUI stuff in programs.*
	programs._1password-gui.enable = true;

	homebrew = {
		enable = true;
		casks = [
			# Karabiner Elements' extensions and services are a little awkward from nix-darwin.
			{ name = "karabiner-elements"; greedy = true; }
			# We expect the same of Tailscale tbh.
			{ name = "tailscale-app"; greedy = true; }
			# Nixpkgs broke it.
			{ name = "rectangle"; greedy = true; }

			{ name = "beeper"; greedy = true; }
			{ name = "signal@beta"; greedy = true; }
			{ name = "calibre"; greedy = true; }

			# https://github.com/macmade/Hot
			# Might package it ourselves at some point.
			{ name = "hot"; greedy = true; }

			{ name = "whatcable"; greedy = true; }
			{ name = "tana"; greedy = true; }
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
		nom
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
		plistwatch
		# FIXME: automatically convert our XCompose files to DefaultKeyBindings.dict and apply it?
		qpkgs.macos-compose
		# Broken right now.
		#harlequin
		# For jj.
		watchman
		# Nixpkgs broke it.
		#ipatool
		jtbl
		pipet
		sacad
		mousecape
		sloth-app

		# Core apps.
		wezterm
		config.programs._1password-gui.package

		# Essential macOS addition.
		# Nixpkgs broke it.
		#rectangle
		thaw

		# Other macOS addition stuff.
		macshot

		# General GUI stuff.
		pinentry_mac
		obsidian
		vesktop
		iina
	];
}
