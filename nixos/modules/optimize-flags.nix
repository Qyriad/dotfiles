# vim: shiftwidth=4 tabstop=4 noexpandtab

{ config, lib, pkgs, ... }:

/** WIP: A NixOS module to store desired CPU optimize flags. */

let
	inherit (lib.options)
		mkOption
	;

	t = lib.types;

	cpuTypeValues = lib.attrNames lib.systems.architectures.features;
	cpuType = t.enum cpuTypeValues;

	cfg = config.optimize-flags;

	knownCpuFlags = {
		"x86-64-v4" = {
			zig = [ "-Dcpu=x86_64_v4" ];
			rust = [ "-C" "target-cpu=x86-64-v4" ];
			gcc = [ "-march=x86-64-v4" ];
		};

		"znver4" = {
			zig = [ "-Dcpu=znver4" ];
			rust = [ "-C" "target-cpu=znver4" ];
			gcc = [ "-march=znver4" "-mtune=znver4" ];
		};
	};

	getCpuFlags =
		cpu:
		lang:
	assert (cpu != null); let
		forCpu = knownCpuFlags.${cpu} or (lib.warn "no known flags for CPU ${cpu}" "");
		forLang = forCpu.${lang} or (lib.warn "no known flags for CPU ${cpu} lang ${lang}" [ ]);
	in forLang;


	# Internal consistency check:
	checkCpuKey = key: lib.assertMsg (cpuType.check key) "CPU type ${key} not valid";
in assert (lib.all (key: assert checkCpuKey key; true) (lib.attrNames knownCpuFlags));
{
	# Interface.
	options.optimize-flags = {
		cpu = mkOption {
			type = t.nullOr cpuType;
			default = null;
			description = "The CPU to optimize for, or `null` for to keep Nixpkgs' -mtune=generic, etc";
		};

		flags.zig = mkOption {
			type = t.listOf t.string;
			description = "The flags to apply for Zig. Set by this module.";
			#readOnly = true;
			example = lib.literalExample (lib.trim ''
				[ "-Dcpu=x86_64_v4" ]
			'');
		};

		flags.rust = mkOption {
			type = t.listOf t.string;
			description = "The flags to apply for the Rust compiler. Set by this module.";
			#readOnly = true;
			example = lib.literalExample (lib.trim ''
				[ "-C" "target-cpu=x86-64-v4" ]
			'');
		};

		flags.gcc = mkOption {
			type = t.listOf t.string;
			description = "The flags to apply for GCC-like compilers. Set by this module.";
			#readOnly = true;
			example = lib.literalExample (lib.trim ''
				[ "-march=x86-64-v4" "-mtune=znver4" ]
			'');
		};
	};

	# Implementation.
	config.optimize-flags = lib.mkIf (cfg.cpu != null) {
		flags.zig = lib.mkOverride 60 (getCpuFlags cfg.cpu "zig");
		flags.rust = lib.mkOverride 60 (getCpuFlags cfg.cpu "rust");
		flags.gcc = lib.mkOverride 60 (getCpuFlags cfg.cpu "gcc");
	};
}
