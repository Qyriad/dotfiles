# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, pkgs, lib, qyriad, ... }:

{
	imports = [
		./modules/darwin-options.nix
		./common.nix
		./dev.nix
	];

	nixpkgs.config.allowUnsupportedSystem = true;

	users.users.qyriad = {
		name = "qyriad";
		description = "Qyriad";
		home = "/Users/qyriad";
	};

	services.nix-daemon.enable = true;

	fonts.fontDir.enable = true;

	system.activationScripts.applications.text = ''
		zsh ${./darwin-activate-applications.zsh} "${config.system.build.applications}"
	'';

	system.defaults = {
		NSGlobalDomain = {
			# Always Use dark mode.
			AppleInterfaceStyle = "Dark";

			# Allow tab-navigating all UI controls.
			AppleKeyboardUIMode = 3;

			# Controls the API pickers and whatnot, not Finder.app.
			AppleShowAllExtensions = true;

			# Expand the save panel by default.
			NSNavPanelExpandedStateForSaveMode = true;
			NSNavPanelExpandedStateForSaveMode2 = true;

			# Don't do any automatic text input things.
			NSAutomaticCapitalizationEnabled = false;
			NSAutomaticDashSubstitutionEnabled = false;
			NSAutomaticPeriodSubstitutionEnabled = false;
			NSAutomaticQuoteSubstitutionEnabled = false;
			NSAutomaticSpellingCorrectionEnabled = false;
		};
		# NSGlobalDomain keys that aren't understood by nix-darwin.
		CustomUserPreferences.NSGlobalDomain = {
			AppleMenuBarVisibleInFullscreen = true;
		};

		dock = {
			autohide = false;
			orientation = "bottom";
			#expose-app-groups = true;
			#tilesize = 44;
		};

		finder = {
			# Controls Finder.app, not API file pickers and whatnot.
			AppleShowAllExtensions = true;

			# Don't warn when changing file extensions.
			FXEnableExtensionChangeWarning = false;
		};
		# com.apple.finder keys that aren't understood by nix-darwin
		CustomUserPreferences."com.apple.finder" = {
			# --group-directories-first
			_FXSortFoldersFirst = true;
		};

		screencapture = {
			location = "~/Pictures/Screenshots";
			type = "png";
		};
		# com.apple.screencapture keys that aren't understood by nix-darwin
		CustomUserPreferences."com.apple.screencapture" = {
			style = "selection";
			target = "file";
		};
	};

	system.keyboard.nonUS.remapTilde = true;
	system.keyboard.enableKeyMapping = true;
	system.keyboard.remapCapsLockToEscape = true;

	programs = {
		nix-index.enable = true;
		#tmux.enable = true;
		zsh = {
			enable = true;
			enableCompletion = true;
			enableBashCompletion = true;
			enableGlobalCompInit = true;
		};
	};

	homebrew = {
		enable = true;
		brews = [
			"mas"
		];

		masApps = {
			Amphetamine = 937984704;
			"1Blocker" = 1365531024;
			Bitwarden = 1352778147;
		};
	};

	#system.activationScripts.extraActivation.text = ''
	#	# Install homebrew
	#	brewVersion="$(/opt/homebrew/bin/brew --version)"
	#	if ! [[ -x "/opt/homebrew/bin/brew" ]]; then
	#		sudo -u qyriad /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	#	fi
	#
	#	# Make sure Rosetta is installed.
	#	if ! [[ -s "/Library/Apple/usr/share/rosetta/rosetta" ]]; then
	#		softwareupdate --install-rosetta
	#	fi
	#
	#	# Ensure SSH is on.
	#	systemsetup -setremotelogin on 2>&1 > /dev/null
	#'';

	environment.systemPackages = with pkgs; [
		ncurses
		neovim
		qyriad.xonsh
		git
		coreutils-full
		iterm2
		karabiner-elements
		rectangle
		gnupg
		plistwatch
		man
		less
	];
}
