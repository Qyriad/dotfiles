-- Because `profile-cond=mp.get_property("current-ao") ~= "coreaudio" and mp.get_property("current-ao") ~= nIl` looks awful and also doesn't actually work
--
local home = os.getenv('HOME')
if string.find(home, [[^/Users]]) then
	--macOS
elseif string.find(home, [[^/home]]) then
	--Linux
	mp.command("set gpu-context wayland")
else
	--Windows
end
