{ pkgs, ... }:

{
	systemd.mounts = let
		shizueOpts = pkgs.qlib.genMountOpts {
			auto = null;
			_netdev = null;
			credentials = "/etc/secrets/shizue.cred";
			gid = "users";
			file_mode = "0764";
			dir_mode = "0775";
			vers = "3.1.1";
		};

		media-shizue-media = {
			type = "cifs";
			what = "//shizue/Media";
			where = "/media/shizue/media";

			after = [ "network-online.target" "multi-user.target" ];
			requires = [ "network-online.target" "multi-user.target" ];
			wantedBy = [ "remote-fs.target" ];
			mountConfig = {
				TimeoutSec = "10s";
				Options = shizueOpts;
			};

			unitConfig = {
				StartLimitIntervalSec = "30s";
				StartLimitBurst = "1";
			};
		};

		media-shizue-archive = {
			type = "cifs";
			what = "//shizue/Archive";
			where = "/media/shizue/archive";

			after = [ "network-online.target" "multi-user.target" ];
			requires = [ "network-online.target" "multi-user.target" ];
			wantedBy = [ "remote-fs.target" ];
			mountConfig = {
				TimeoutSec = "10s";
				Options = shizueOpts;
			};
		};
	in [
		media-shizue-media
		media-shizue-archive
	];
}
