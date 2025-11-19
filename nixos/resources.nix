# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, lib, ... }:

/** A NixOS module to let each host declare numbers for their hardware resources,
which we then do Math™ on.
*/

{
	# Interface.
	options.resources = {
		memory = lib.mkOption {
			type = lib.types.int;
			default = 8;
			description = "Amount of physical memory this system has, in gibibytes";
			example = lib.literalExpression <| lib.dedent ''
				32
			'';
		};

		cpus = lib.mkOption {
			type = lib.types.int;
			default = 8;
			description = "Amount of CPU cores this system has. Basically the output of nproc.";
			example = lib.literalExpression <| lib.dedent ''
				16
			'';
		};

		builderSliceConfig = lib.mkOption {
			type = lib.types.attrs;
			visible = false;
			readOnly = true;
		};
	};

	# Implementation.
	config = let
		inherit (builtins) floor;
		mostCpus = floor (config.resources.cpus * 0.80);
		mostMemory = floor (config.resources.memory * 0.80);
		maxMemory = floor (config.resources.memory * 0.85);
	in {
		resources.builderSliceConfig = {
			CPUWeight = lib.mkDefault "90";
			CPUQuota = "${toString (mostCpus * 90)}%";
			MemoryHigh = "${toString mostMemory}G";
			MemoryMax = "${toString maxMemory}G";
			IOWeight = 20;
			MemoryAccounting = true;
			IOAccounting = true;
		};

		nix.settings.cores = mostCpus;
	};
}
