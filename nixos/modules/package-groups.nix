# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, lib, pkgs, ... }:

let
	inherit (lib.options)
		mkOption
	;
	t = lib.types;

	cfg = config.package-groups;
in
{
	# Interface.
	options = {
		package-groups.music-production.enable = mkOption {
			type = t.bool;
			default = false;
			description = "Enable music production software";
		};
		package-groups.music-production.remove-packages = mkOption {
			type = t.listOf t.package;
			default = [ ];
			description = "Packages normally included in music-production to instead not include.";
		};
		package-groups.music-production.default-packages = mkOption {
			type = t.listOf t.package;
			readOnly = true;
			default = with pkgs; [
				bitwig-studio
				ardour
				musescore
				fluidsynth
				soundfont-ydp-grand
				soundfont-fluid
				tenacity
			];
		};
		package-groups.music-production.final-packages = mkOption {
			type = t.listOf t.package;
			internal = true;
		};

		package-groups.wayland-tools.enable = mkOption {
			type = t.bool;
			default = false;
			description = "Enable helpful Wayland software";
		};
		package-groups.wayland-tools.remove-packages = mkOption {
			type = t.listOf t.package;
			default = [ ];
			description = "Packages normally included in wayland-tools to instead not include.";
		};
		package-groups.wayland-tools.default-packages = mkOption {
			default = with pkgs; [
				wl-clipboard
				waypipe
				wayvnc
				kooha
				wev
			];
		};
		package-groups.wayland-tools.final-packages = mkOption {
			type = t.listOf t.package;
			internal = true;
		};
	};

	# Implementation.
	config = {
		# Internal finals.
		package-groups = {
			music-production.final-packages = lib.filter (pkg:
				! (lib.elem pkg cfg.music-production.remove-packages)
			) cfg.music-production.default-packages;

			wayland-tools.final-packages = lib.filter (pkg:
				! (lib.elem pkg cfg.wayland-tools.remove-packages)
			) cfg.wayland-tools.default-packages;
		};

		# External effects.
		environment.systemPackages = let
			musicProduction = lib.optionals cfg.music-production.enable cfg.music-production.final-packages;
			waylandTools = lib.optionals cfg.wayland-tools.enable cfg.wayland-tools.final-packages;
		in musicProduction
		++ waylandTools;
	};
}
