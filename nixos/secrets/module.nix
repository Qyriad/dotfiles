{ lib, config, options, ... }:

lib.mkIf (options ? age) {
	age.secrets.shizue-cred = {
		file = ./shizue-cred.age;
		group = config.users.groups.wheel.name;
		mode = "0440";
	};
}
