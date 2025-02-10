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
	};

	# Implementation.
	config = {
		# Internal finals.
		package-groups = {
			music-production.final-packages = lib.filter (pkg:
				! (lib.elem pkg cfg.music-production.remove-packages)
			) cfg.music-production.default-packages;
		};

		# External effects.
		environment.systemPackages = let
			musicProduction = lib.optionals cfg.music-production.enable cfg.music-production.final-packages;
		in musicProduction
		++ [ ];
	};
}
