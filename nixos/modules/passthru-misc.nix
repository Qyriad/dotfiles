# vim: shiftwidth=2 tabstop=2 noexpandtab
/**
 Miscellaneous passthru attributes to aide in debugging or exploration.
*/
{ options, lib, ... }:

{
	passthru.sessionVariableLocationsByVar = options.environment.sessionVariables.definitionsWithLocations
	|> lib.map ({ file, value }: value |> lib.mapAttrs (_: varVal: { inherit file; value = varVal; }));
}
