# vim: shiftwidth=4 tabstop=4 noexpandtab
{ pkgs, config, ... }:

{
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
		media-shizue-media
		media-shizue-archive
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
