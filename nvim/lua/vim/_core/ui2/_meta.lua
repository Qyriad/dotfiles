---@meta
error('Cannot require a meta file')

-- Patching in type annotations for Neovim's half-documented, experimental
-- vim._core.ui2 feature.

---@class vim._core.ui2.cfg.msg.Cmd
---Options related to messages in the cmdline window.
---@field height number Maximum height while expanded for messages beyond 'cmdheight'

---@class vim._core.ui2.cfg.msg.Dialog
---Options related to dialog window.
---@field height number Maximum height.

---@class vim._core.ui2.cfg.msg.Msg
---Options related to the msg window.
---@field height number
---@field timeout number Time a message is visible in the message window

---@class vim._core.ui2.cfg.msg.Pager
---Options related to message window.
---@field height number Maximum height

---@class vim._core
vim._core = ...

---@class vim._core.ui2
vim._core.ui2 = ...
---@class vim._core.ui2.Cfg
---@field enable? boolean Whether the experimental UI2 feature is enabled.
vim._core.ui2.cfg = ...

---@class vim._core.ui2.cfg.Msg
---@field target? 'cmd'|'msg'
---@field targets? table<string, 'cmd'|'msg'|'pager'>
---@field cmd? vim._core.ui2.cfg.msg.Cmd
---@field dialog? vim._core.ui2.cfg.msg.Dialog
---@field msg? vim._core.ui2.cfg.msg.Msg
---@field pager? vim._core.ui2.cfg.msg.Pager
vim._core.ui2.cfg.msg = ...

---@param opts vim._core.ui2.Cfg
---The line number will certainly change over time but that's fine.
---@source /usr/share/nvim/runtime/lua/vim/_core/ui2.lua:174
function vim._core.ui2.enable(opts) end
