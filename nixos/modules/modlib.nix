# vim: shiftwidth=4 tabstop=4 noexpandtab
{ lib, options, config, ... }:

/** Library functions that operate on a NixOS configuration.
 *
 * Honestly this is probably not at all the best way to do this but whatever.
 */

let
	t = lib.types;
in
{
	options.modlib = {
		usersInGroup = lib.mkOption {
			internal = true;
			type = t.functionTo (options.users.users.type);
		};
	};

	config.modlib = {
		usersInGroup = group:
			assert
				lib.assertMsg (lib.isString group)
				"modlib.usersInGroups `group` incorrect argument type: ${lib.typeOf group}"
			;

			config.users.users
			|> lib.filterAttrs (name: user: user.group == group || lib.elem group user.extraGroups);
	};
}
