# vim: shiftwidth=4 tabstop=4 noexpandtab
{ pkgs, lib, ... }:

{
	imports = [
		./common.nix
		# FIXME: this import should probably be moved to a generic darwin.nix or something.
		./modules/darwin-nixos-compat.nix
	];

	system.stateVersion = 5;

	nixpkgs.config.allowUnfree = true;
	ids.gids.nixbld = 30000;

	networking.computerName = "Keyleth";
	networking.localHostName = "Keyleth";

	nix = {
		settings = {
			experimental-features = [
				"nix-command"
				"flakes"
				"pipe-operator"
				"no-url-literals"
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

	environment.systemPackages = with pkgs; [
		#qyriad.xil
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
		harlequin
		ipatool
		jtbl
		imgp
		pipet
		sacad
		mousecape
		sloth-app
	];
}
