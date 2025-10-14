# vim: shiftwidth=4 tabstop=4 noexpandtab
/** This is a function-that-returns-a-module, used with `lib.modules.importApply`.
 */
flake:

{ lib, config, ... }:

let
	csi = builtins.fromJSON ''"\u001b"'';
	green = "${csi}[32m";
  	normal = "${csi}[0m";
	bold = "${csi}[1m";
in
{
	config = {
		nixpkgs.overlays = [
			flake.overlays.default
		];

		# Prevent our flake input trees from being garbage collected.
		storePathsToKeep = flake.inputs;

		# Point "qyriad" to this here flake.
		nix.registry.qyriad = {
			from = { id = "qyriad"; type = "indirect"; };
			flake = flake;
		};

		# Experimental: literally just add *all* our flake inputs as <nixPath> things.
		nix.nixPath = lib.removeAttrs flake.inputs [ "nixpkgs" ]
		|> lib.attrsToList
		|> lib.map ({ name, value }: "${name}=${value}")
		|> lib.trivial.concat [ "nixpkgs=flake:nixpkgs" ];

		nixpkgs.flake.source = flake.inputs.nixpkgs.outPath;

		# And for fun, let NixOS know our Git commit hash, if we have one.
		system.configurationRevision = let
			rev = flake.rev or flake.dirtyRev or "unknown";
			sysName = config.system.name or config.system.darwinLabel;
			msg = lib.trim ''
				${green}note${normal}: '${sysName}' system configuration revision ${bold}${rev}${normal}
			'';
		in builtins.trace msg rev;
	};
}
