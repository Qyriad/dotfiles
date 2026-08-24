# vim: shiftwidth=0 tabstop=2 noexpandtab
{ config, lib, pkgs, utils, ... }:
let
	inherit (lib.options) mkOption;
	inherit (utils.systemdUtils.lib) settingsToSections;
	inherit (utils.systemdUtils.unitOptions) unitOption;
	t = lib.types;
	cfg = config.services.resolved.dnssd.services;

	serviceType = t.submodule {
		freeformType = t.attrsOf unitOption;

		options = {
			Port = mkOption {
				type = t.port;
				description = "An IP port number of the network service.";
			};
		};
	};
in
{
	options = {
		services.resolved.dnssd.services = mkOption {
			description = "DNS-SD service definition files for /etc/systemd/dnssd/";
			type = t.attrsOf (t.submodule {
				options.Service = mkOption {
					description = "The [Service] section of the .dnssd file";
					type = serviceType;
				};
			});
		};
	};

	config = {
		environment.etc = cfg
		|> lib.mapAttrs' (name: { ... }@service: {
			name = "systemd/dnssd/${name}.dnssd";
			value.text = settingsToSections service;
		});
	};
}
