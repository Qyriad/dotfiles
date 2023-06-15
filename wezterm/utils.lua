local module = { table = {} }

-- Values in `second` take precedence.
-- Returns a new table and does not modify either original.
function module.table.combine(first, second)
	if first == nil then
		wezterm.log_error("table.combine(first) called with nil; second =")
		wezterm.log_error(second)
		error("table.combine(first) called with nil")
	end
	if second == nil then
		wezterm.log_error("table.combine(second) called with nil; first =")
		wezterm.log_error(first)
		error("table.combine(second) called with nil")
	end
	local out = {}
	for k, v in pairs(first) do
		out[k] = v
	end
	for k, v in pairs(second) do
		out[k] = v
	end
	return out
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

function module.current_gui_window()
	for _, gui_window in ipairs(wezterm.gui.gui_windows()) do
		if gui_window:is_focused() then
			return gui_window
		end
	end
end

function module.current_mux_domain()
	local current_gui_window = module.current_gui_window()
	local current_mux_pane = current_gui_window:mux_window():active_pane()
	local current_mux_domain = wezterm.mux.get_domain(current_mux_pane:get_domain_name())
	return current_mux_domain
end

return module
