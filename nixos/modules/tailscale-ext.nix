{ lib, config, ... }:
let
	t = lib.types;
in
{
	options = {
		services.tailscale.encryptState = lib.mkOption {
			type = t.bool;
			default = false;
			description = lib.dedent ''
				Encrypt the state file on disk via TPM.
			'';
		};
	};

	config = lib.mkIf config.services.tailscale.encryptState {
		services.tailscale.extraDaemonFlags = [ "--encrypt-state" ];
	};
}
