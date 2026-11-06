# vim: shiftwidth=2 tabstop=2 noexpandtab
{ pkgs, config, ... }:

{

	fileSystems = let
		shizueOpts = [
			"noauto"
			"_netdev"
			"nofail"
			"mfsymlinks"
			"cifsacl"
			"noperm"
			"idsfromsid"
			"setuids"
			"vers=3.1.1"
			"credentials=${config.age.secrets.shizue-cred.path}"
			"x-systemd.requires=network-online.target"
			"x-systemd.automount"
			"x-systemd.mount-timeout=10s"
		];
	in {
		"/media/shizue/media" = {
			options = shizueOpts;
			device = "//shizue.local/Media";
			fsType = "cifs";
		};
		"/media/shizue/archive" = {
			options = shizueOpts;
			device = "//shizue.local/Archive";
			fsType = "cifs";
		};
	};

	#fileSystems."/media/shizue/media" = {
	#	device = "//shizue.local/Media";
	#	fsType = "cifs";
	#};
	#
	#fileSystems."/media/shizue/archive" = {
	#	options = [
	#		"noauto"
	#		"_netdev"
	#		"nofail"
	#		"mfsymlinks"
	#		"cifsacl"
	#		"noperm"
	#		"idsfromsid"
	#		"setuids"
	#		"vers=3.1.1"
	#		"credentials=${config.age.secrets.shizue-cred.path}"
	#		"x-systemd.requires=network-online.target"
	#		"x-systemd.automount"
	#		"x-systemd.mount-timeout=10s"
	#	];
	#	device = "//shizue.local/Archive";
	#	fsType = "cifs";
	#};

	systemd.timers.graphical-late = {
		after = [ "graphical.target" ];
		wantedBy = [ "graphical.target" ];
		timerConfig.Unit = "graphical-late.target";
		timerConfig.OnActiveSec = "60";
	};
	systemd.targets.graphical-late = {
		requisite = [ "graphical.target" "local-fs.target" ];
	};

	systemd.targets.logged-in = {
		bindsTo = [ "user@1000.service" ];
	};

	systemd.services."user@" = {
		overrideStrategy = "asDropin";
		upholds = [ "logged-in.target" ];
	};

	systemd.mounts = let
		shizueOpts = pkgs.qlib.genMountOpts {
			noauto = null;
			_netdev = null;
			nofail = null;
			#gid = "users";
			#file_mode = "0764";
			#dir_mode = "0775";
			mfsymlinks = null;
			cifsacl = null;
			noperm = null;
			idsfromsid = null;
			setuids = null;
			vers = "3.1.1";
			credentials = config.age.secrets.shizue-cred.path;
		};

		after = [
			"network-online.target"
			#"avahi-daemon.service"
			"local-fs.target"
			"nss-lookup.target"
		];
		requires = after;

		mountConfig = {
			TimeoutSec = "10s";
			Options = shizueOpts;
		};

		unitConfig = {
			#StartLimitIntervalSec = "30s";
			#StartLimitBurst = "3";
			#StopPropagatedFrom = [
			#	"network-online.target"
			#];
		};

		#wantedBy = [ "multi-user.target" ];
		wantedBy = [ ];

		media-shizue-media = {
			type = "cifs";
			what = "//shizue.local/Media";
			where = "/media/shizue/media";

			inherit after requires wantedBy mountConfig unitConfig;
		};

		media-shizue-archive = {
			type = "cifs";
			what = "//shizue.local/Archive";
			where = "/media/shizue/archive";

			inherit after requires wantedBy mountConfig unitConfig;
		};
	in [
		#media-shizue-media
		#media-shizue-archive
	];

	#systemd.automounts = let
	#	media-shizue-media = {
	#		where = "/media/shizue/media";
	#	};
	#in [
	#	media-shizue-media
	#];

	age.secrets.shizue-cred = {
		file = ./secrets/shizue-cred.age;
		group = config.users.groups.wheel.name;
		mode = "0440";
	};
}
