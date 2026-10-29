{ config, lib, pkgs, ... }:
let
	inherit (lib.options) mkEnableOption mkPackageOption;
	cfg = config.services.midiminder;
in
{
	# Interface.
	options = {
		services.midiminder.enable = mkEnableOption "midiminder";
		services.midiminder.package = mkPackageOption pkgs "midiminder" {
			default = [ "qpkgs" "midiminder" ];
		};
	};

	# Implementation.
	config = lib.mkIf cfg.enable {
		users.users.midiminder = {
			isSystemUser = true;
			packages = [ cfg.package ];
			group = "midiminder";
			extraGroups = [ "audio" ];
		};
		users.groups.midiminder = { };
		users.groups.audio = { };

		environment.systemPackages = [ cfg.package ];
		systemd.packages = [ cfg.package ];

		systemd.services.midiminder = {
			overrideStrategy = "asDropin";
			wantedBy = [ "default.target" ];
		};
	};
}
