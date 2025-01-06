# vim: shiftwidth=4 tabstop=4 noexpandtab
{ pkgs, lib, ... }:

{
	system.stateVersion = 5;

	imports = [
	  ./common.nix
	];

	nixpkgs.config.allowUnfree = true;
	services.nix-daemon.enable = true;

	nix = {
		settings = {
			experimental-features = [ "nix-command" "flakes" "pipe-operator" ];
			trusted-users = [ "qyriad" ];
			repl-overlays = [ ../nix/repl-overlay.nix ];
		};

		nixPath = [ "nixpkgs=flake:nixpkgs" ];
	};

	system.keyboard = {
		enableKeyMapping = true;
		remapCapsLockToEscape = true;
	};

	programs.nix-index.enable = true;

	programs.zsh = {
		enable = true;
		enableCompletion = true;
		enableBashCompletion = true;
		enableGlobalCompInit = true;
	};

	system.defaults = {
		NSGlobalDomain = {
			# System Preferences -> Keyboard -> Key repeat rate: "Fast".
			KeyRepeat = 2;

			# System Preferences -> Keyboard -> Keyboard navigation.
			AppleKeyboardUIMode = 3;

			# Finder -> Preferences -> Advanced -> Show all filename extensions.
			AppleShowAllExtensions = true;
		};

		finder = {
			# Finder -> Preferences -> Advanced -> Keep folders on top: "When sorting by name".
			# defaults write "com.apple.finder" "_FXSortFoldersFirst" 1.
			_FXSortFoldersFirst = true;
		};

		trackpad = {
			# System Preferences -> Trackpad -> Tap to click.
			# defaults write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "Clicking" 1
			Clicking = true;
		};

		controlcenter = {
			# System Preferences -> Control Center -> Battery -> Show Percentage.
			# defaults -currentHost write "com.apple.controlcenter" "BatteryShowPercentage" 1
			BatteryShowPercentage = true;
		};


		CustomUserPreferences."com.apple.Safari" = {
			# Safari -> Preferences -> Remove history items: "Manually".
			HistoryAgeInDaysLimit = 365000;
			# View -> Show Status Bar.
			ShowOverlayStatusBar = 1;
			# Safari -> Preferences -> Advanced -> Show full website address.
			ShowFullURLInSmartSearchField = 1;
			# Safari -> Preferences -> General -> Safari opens with: "All windows from last session".
			AlwaysRestoreSessionAtLaunch = 1;
			ExcludePrivateWindowWhenRestoringSessionAtLaunch = 0;
			# Safari -> Preferences -> Autofill -> User names and passwords.
			AutoFillPasswords = 0;


			# Safari -> Preferences -> Advanced -> Default encoding: "Unicode (UTF-8)".
			WebKitDefaultTextEncodingName = "utf-8";
			"WebKitPreferences.defaultTextEncodingName" = "utf-8";

			# Safari -> Preferences -> Advanced -> Allow privacy-preserving measurement of ad effectiveness.
			"WebKitPreferences.privateClickMeasurementEnabled" = 0;

			# Safari -> Preferences -> Advanced -> Show features for web developers.
			IncludeDevelopMenu = 1;
			WebKitDeveloperExtrasEnabledPreferenceKey = 1;
			"WebKitPreferences.developerExtrasEnabled" = 1;
		};

		CustomUserPreferences."com.apple.Safari.SandboxBroker" = {
			# Safari -> Preferences -> Advanced -> Show features for web developers.
			"ShowDevelopMenu" = 1;
		};

	};

	homebrew = {
		enable = true;
		casks = [
			"wezterm"
		];
	};

	environment.systemPackages = with pkgs; [
		qyriad.xonsh
		neovim
		tmux
		eza
		fd
		ripgrep
		#qyriad.xil
		qyriad.niz
		moar
		grc
		plistwatch
		qyriad.git-point
		nixpkgs-review
		nixfmt-rfc-style
		nil
		nix-output-monitor
		nix-index
		rustup
		vesktop
		wezterm
		rectangle
	];
}
