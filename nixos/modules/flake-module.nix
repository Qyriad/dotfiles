# vim: shiftwidth=4 tabstop=4 noexpandtab
/** This is a function-that-returns-a-module, used with `lib.modules.importApply`.
 */
flake:

# Technically this module doesn't need to be a function, but is for clarity and type-checking.
{ ... }:

{
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

	nixpkgs.flake.source = flake.inputs.nixpkgs.outPath;

	# And for fun, let NixOS know our Git commit hash, if we have one.
	system.configurationRevision = flake.rev or flake.sourceInfo.dirtyRev;
}
