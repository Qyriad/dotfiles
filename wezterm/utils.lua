local module = { table = {} }

-- Values in `second` take precedence.
-- Returns a new table and does not modify either original.
function module.table.combine(first, second)
	local out = {}
	for k, v in pairs(first) do
		out[k] = v
	end
	for k, v in pairs(second) do
		out[k] = v
	end
end


function module.tab_title(tab_info)
	local title = tab_info.tab_title
	-- If the tab title is explicitly set, use that.
	if title and #title > 0 then
		return title
	end

	-- Otherwise, use the title from the active pane in that tab.
	return tab_info.active_pane.title
end

function module.basename(path)
	if path == nil then
		return nil
	end
	return string.gsub(path, "(.*[/\\])(.*)", "%2")
end

return module
