# vim: shiftwidth=4 tabstop=4 noexpandtab
{ pkgs, ... }:

{
	networking.hostName = "dataovermind";
	#networking.networkmanager = {
	#	enable = true;
	#};
	#networking.useHostResolvConf = false;
	#services.resolved.enable = true;
	#systemd.network = {
	#	enable = true;
	#};

	environment.systemPackages = with pkgs; [
		fd
		ripgrep
		eza
	];

	environment.shellAliases = {
		"ls" = "eza -l --header --group --group-directories-first --classify --binary";
	};

	services.home-assistant = {
		enable = true;
		openFirewall = true;
		configWritable = true;
		config.homeassistant = {
			name = "dataovermind";
			unit_system = "metric";
			temperature_unit = "C";
			auth_providers = let
				trustedNetworks = {
					type = "trusted_networks";
					# Allow anyone on localhost to login instantly.
					allow_bypass_login = true;
					trusted_networks = [
						"127.0.0.1"
						"192.168.1.0/24"
						"192.168.50.0/24"
						"100.64.0.0/10"
					];
				};

				default = { type = "homeassistant"; };
			in [
				trustedNetworks
				default
			];
		};
		config.default_config = { };
		extraComponents = [
			# Components required to complete the onboarding.
			"met"
			"esphome"
			"radio_browser"
			#"pluralkit"

			# General core components.
			#"wake_word"
			#"conversation"
			#"homekit_controller"
		];
		extraPackages = pyPkgs: with pyPkgs; [
			aiovlc
			buienradar
			dsmr-parser
			pyvesync
			pyatv
			pynacl
			aioqsw
			gtts
			adb-shell
			androidtv
			androidtvremote2
			notifications-android-tv
			pychromecast
			#wyoming
			hap-python
			ibeacon-ble
			aiohomekit
			aioharmony
			python-kasa
			hass-nabucasa
			python-otbr-api
			setuptools
			nextcord
			python-matter-server
			pyipp
			aioshelly
			getmac
			wled
			brother
			radios
			#pkgs.ha-pluralkit
		];

		customComponents = [
			#pkgs.ha-pluralkit
		];
	};
}
