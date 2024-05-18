# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, pkgs, modulesPath, inputs, ... }:

{
	imports = [
		(modulesPath + "/virtualisation/qemu-vm.nix")
		./yuki-hardware.nix
		./common.nix
		./linux.nix
		./resources.nix
		inputs.buildbot-lix.nixosModules.buildbot-coordinator
		inputs.buildbot-lix.nixosModules.buildbot-worker
	];

	resources = {
		memory = 16;
		cpus = 8;
	};

	networking.hostName = "buildbot-yuki";
	users.users.root = {
		password = "root-password";
		openssh.authorizedKeys.keys = [
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDI6Tdxcbr3XSD2Ok2tUb4RJ3nOszqKklkqXUrgnFM1F cardno:26_907_287"
		];
	};

	virtualisation.forwardPorts = let
		sshAs2222 = {
			from = "host";
			host.port = 2222;
			guest.port = 22;
		};
	in [
		sshAs2222
	];

	services.openssh.settings = {
		PermitRootLogin = "yes";
	};

	services.buildbot-nix.worker = {
		enable = true;
		workerArchitectures = {
			x86_64-linux = 8;
		};
		workerPasswordFile = builtins.toFile "workerPasswordFile" "bbworker-password";
	};

	#environment.systemPackages = [
	#	config.services.buildbot-nix.worker.package
	#	config.services.buildbot-nix.worker.package.pythonModule.pkgs.twisted
	#];

	systemd.services.buildbot-master.path = [ pkgs.openssh ];

	services.buildbot-nix.coordinator = {
		enable = true;
		domain = "buildbot-yuki";
		buildSystems = [ "x86_64-linux" ];
		# Becomes `self.nix_workers_secret_name` in Gerrit configurator.
		workersFile = let
			localWorker = {
				cores = 8;
				name = "yuki-buildbot-worker-thing";
				pass = "bb-worker-password";
			};
			# Why is this an array?
			fullConfig = builtins.toJSON [
				localWorker
			];
		in builtins.toFile "workersFile" fullConfig;
		oauth2SecretFile = builtins.toFile "oauth2SecretFile" "bb-oauth2";

		gerrit = {
			domain = "gerrit.lix.systems";
			username = "foo";
			port = 2222;
		};
	};

	#environment.systemPackages = [
	#	config.services.buildbot-master.package
	#	#pkgs.buildbot
	#	pkgs.buildbot-worker
	#];
}
