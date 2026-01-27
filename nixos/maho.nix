# vim: shiftwidth=4 tabstop=4 noexpandtab
{ pkgs, lib, ... }:

{
	imports = [
		./common.nix
		# FIXME: this import should probably be moved to a generic darwin.nix or something.
		./modules/darwin-nixos-compat.nix
	];

	system.stateVersion = 6;

	nixpkgs.config.allowUnfree = true;
	#ids.gids.nixbld = 30000;

	networking.computerName = "Maho";
	networking.localHostName = "Maho";

	#programs.neovim.enable = true;

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

	programs.bash.completion.enable = true;

	programs.gnupg.agent = {
		enable = lib.mkForce false;
	};

	homebrew = {
		enable = true;
		casks = [
			"wezterm"
		];
	};

	programs.tmux = {
		enable = true;
	};

	environment.enableAllTerminfo = true;

	environment.systemPackages = with pkgs; [
		#qyriad.xil
		neovim
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
	];
}
