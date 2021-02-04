function lua_list_extend(original, new)
	for i = 1, #new do
		table.insert(original, new[i])
	end
end

function vim_list_cat(original, new)
	local l = { }
	for i = 1, #original do
		table.insert(l, original[i])
	end
	lua_list_extend(l, new)
	return l
end

