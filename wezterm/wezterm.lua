_G.wezterm = require("wezterm") ---@type Wezterm

_G.utils = require("utils")

local inspect = require("inspect")
_G.inspect = inspect
wezterm.inspect = inspect

--
-- Shortcut helpers.
--

local on_macos = string.find(wezterm.target_triple, "darwin") ~= nil

local function bind_leader(key, action, extra_mods)
	local mods = "LEADER"
	if extra_mods ~= nil then
		mods = mods .. "|" .. extra_mods
	end
	return {
		key = key,
		mods = mods,
		action = action,
	}
end

local _bind_os_options = {
	ctrl_shift = false,
}

-- Binds CTRL+SHIFT+{key} on Windows and Linux, or SUPER+{key} on macOS.
local function bind_os(key, action, options)
	options = utils.table.combine(_bind_os_options, options or {}) -- Allow `options` to be nil.

	local mods
	if on_macos then
		mods = "SUPER"
	else
		if options.ctrl_shift == true then
			mods = "CTRL|SHIFT"
		else
			mods = "CTRL"
		end
	end

	return {
		key = key,
		mods = mods,
		action = action,
	}
end

local font_list = { }

if on_macos then
	font_list[1] = "Monaco"
else
	font_list[1] = "InconsolataGo Nerd Font Mono"
end

--
-- Actual config
--

local config = wezterm.config_builder()

---@param tbl Config
---@return Config
local function conf(tbl)
	utils.table.merge(config, tbl)
	return config
end

conf {
	tab_bar_at_bottom = true,
	use_fancy_tab_bar = true,
	hide_tab_bar_if_only_one_tab = true,
	use_ime = true,
	log_unknown_escape_sequences = true,
	alternate_buffer_wheel_scroll_speed = 5,
}

---@param tab TabInformation,
---@param tabs TabInformation[],
---@param panes PaneInformation[],
---@param config Config,
---@param hover boolean,
---@param max_width number
local function format_tab_title(tab, tabs, panes, config, hover, max_width)
	local title = utils.tab_title(tab)

	local pane = tab.active_pane
	local process_name
	if pane.domain_name == "local" then
		process_name = utils.basename(pane.foreground_process_name)
	else
		local user_vars = pane.user_vars
		local cmdline = user_vars.WEZTERM_PROG or "xonsh"
		local progname_end = string.find(cmdline, " ")
		process_name = string.sub(cmdline, 1, progname_end)
	end

	local new_output = ""
	if pane.has_unseen_output then
		new_output = " *"
	end

	process_name = process_name or "␀"

	return string.format("%s:%s %s%s ", tab.tab_index + 1, process_name, title, new_output)

end

wezterm.on("format-tab-title", format_tab_title)

wezterm.on('update-right-status', function(window, pane)
	--local dt = wezterm.stftime('%Y-%m')
	local display = wezterm.to_string
	local dn = display(pane:get_domain_name())
	local title = display(pane:get_title())
	window:set_right_status(wezterm.format{
		--{ Foreground = { AnsiColor = "magenta" } },
		{ Text = string.format('%s | %s', display(pane), title)}
	})
end)

conf {
	default_prog = { "zsh", "--login" },
	font = wezterm.font("InconsolataGo Nerd Font Mono"),
	--font_size = 11.5,
	font_size = 12,

	window_decorations = "TITLE|RESIZE",

	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},

	window_frame = {
		border_bottom_height = "0cell",
		border_top_height = "0cell",
	},

	-- I'm not using these. Clear up my command palette.
	ssh_domains = { },

	bold_brightens_ansi_colors = "No",
}

-- Multiplexing.
config.default_domain = "local"

-- Main keybindings. Set up to act kind of like our tmux config.
--config.leader = {
--	key = "`"
--}

config.keys = {
	---- Equivalent to `bind-key -T prefix "`" send-prefix`
	--bind_leader("`", wezterm.action.SendString("`")),
	--
	---- Equivalent to `bind-key -T prefix '"' split-window -v`
	---- domain = "CurrentPaneDomain" is the default.
	--bind_leader('"', wezterm.action.SplitVertical { }, "SHIFT"),
	--
	---- Equivalent to `bind-key -T prefix "%" split-window -h`
	--bind_leader("%", wezterm.action.SplitHorizontal { }, "SHIFT"),
	--
	---- Equivalent to `bind-key -T prefix "c" new-window
	--bind_leader("c", wezterm.action.SpawnTab("CurrentPaneDomain")),
	--
	---- Equivalent to `bind-key -T prefix "n" next-window
	--bind_leader("n", wezterm.action.ActivateTabRelative(1)),
	--
	---- Equivalent to `bind-key -T prefix "p" previous-window
	--bind_leader("p", wezterm.action.ActivateTabRelative(-1)),
	--
	---- Equivalent to bind-key -T prefix "x" confirm-before -p "kill-pane #P? (y-n) kill-pane"
	--bind_leader("x", wezterm.action.CloseCurrentPane { confirm = true }),
	--
	---- Equivalent to bind-key -T prefix "h" select-pane -L
	--bind_leader("h", wezterm.action.ActivatePaneDirection("Left")),
	--
	---- Equivalent to bind-key -T prefix "j" select-pane -D
	--bind_leader("j", wezterm.action.ActivatePaneDirection("Down")),
	--
	---- Equivalent to bind-key -T prefix "k" select-pane -U
	--bind_leader("k", wezterm.action.ActivatePaneDirection("Up")),
	--
	---- Equivalent to bind-key -T prefix "l" select-pane -L
	--bind_leader("l", wezterm.action.ActivatePaneDirection("Right")),
	--
	---- Equivalent to `bind-key -T prefix "-" select-window -l`
	--bind_leader("-", wezterm.action.ActivateLastTab),
	--
	---- Equivalent to `bind-key -T prefix "z" resize-pane -Z`
	--bind_leader("z", wezterm.action.TogglePaneZoomState),
	--
	---- Equivalent to `bind-key -T prefix "[" copy-mode`
	--bind_leader("[", wezterm.action.ActivateCopyMode),
	--
	--bind_leader("d", wezterm.action.DetachDomain "CurrentPaneDomain"),
	--
	--bind_leader(":", wezterm.action.ActivateCommandPalette),
	--bind_leader(";", wezterm.action.ActivateCommandPalette),
	--
	--bind_leader("1", wezterm.action.ActivateTab(0)),
	--bind_leader("2", wezterm.action.ActivateTab(1)),
	--bind_leader("3", wezterm.action.ActivateTab(2)),
	--bind_leader("4", wezterm.action.ActivateTab(3)),
	--bind_leader("5", wezterm.action.ActivateTab(4)),
	--bind_leader("6", wezterm.action.ActivateTab(5)),
	--bind_leader("7", wezterm.action.ActivateTab(6)),
	--bind_leader("8", wezterm.action.ActivateTab(7)),
	--bind_leader("9", wezterm.action.ActivateTab(8)),
	--bind_leader("0", wezterm.action.ActivateTab(0)),

	bind_os("c", wezterm.action.CopyTo("Clipboard"), { ctrl_shift = true }),
	bind_os("v", wezterm.action.PasteFrom("Clipboard"), { ctrl_shift = true }),

	bind_os("-", wezterm.action.DecreaseFontSize),
}

config.key_tables = { }

config.key_tables.copy_mode = {
}

config.mouse_bindings = {
	{
		event = { Up = { streak = 1, button = "Left", } },
		mods = "SUPER",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
	{
		event = { Up = { streak = 1, button = "Left", } },
		mods = "NONE",
		action = wezterm.action.CompleteSelection("Clipboard"),
	},
}

config.colors = {
	--foreground = "#c7c7c7",
	foreground = "#eaeaea",
	background = "#000000",

	cursor_bg = "#c7c7c7",

	ansi = {
		-- Black.
		"#222222",

		-- Red.
		--"#cf0002", <-- that a touch too little contrast against black, so I lightened
		-- it a bit.
		-- `pastel color "#cf0002" | pastel lighten 0.05`:
		"#e90004",

		-- Green.
		"#00cc00",

		-- Yellow.
		"#e6c540",

		-- Blue.
		"#0aa6da",

		-- Magenta.
		"#b043fe",

		-- Cyan.
		--"#70c0ba",
		--"darkcyan",

		-- `pastel color darkcyan | pastel lighten 0.05 | pastel saturate 0.05`
		-- "#00a5a5", approximately:
		"lightseagreen",

		-- White.
		"#ffffff",
	},

	brights = {
		-- Black.
		"#666666",

		-- Red.
		"#ff3334",

		-- Green.
		"#9ec400",

		-- Yellow.
		"#e7c547",

		-- Bright Blue.
		--"#7aa6da",
		"aqua",

		-- Magenta.
		"#b77ee0",

		-- Bright Cyan.
		--"#54ced6",
		-- `pastel color darkcyan | pastel lighten 0.15 | pastel desaturate 0.05`:
		"#05d2d2",

		-- White.
		"#ffddff",
	},

	--ansi = {
	--	--"#000000", -- Black
	--	"#222222", -- Black
	--	--"#c91b00", -- Red
	--	"#cf0002", -- Red
	--	"#00c200", -- Green
	--	"#c7c400", -- Yellow
	--	"#0225c7", -- Blue
	--	"#c930c7", -- Magenta
	--	--"#c930c7", -- Magenta
	--	"#00c5c7", -- Cyan
	--	"#c7c7c7", -- White
	--},
	--brights = {
	--	"#676767", -- Black
	--	--"#ff6d67", -- Red
	--	"#ff3334", -- Red
	--	"#5ff967", -- Green
	--	"#fefb67", -- Yellow
	--	"#6871ff", -- Blue
	--	"#ff76ff", -- Magenta
	--	"#5ffdff", -- Cyan
	--	"#fffeff", -- White
	--},
}

wezterm.on("mux-is-process-stateful", function(process)
	local is_xonsh = process.argv[1] == "xonsh"
	if is_xonsh then
		return false
	end
	return nil
end)

return config
