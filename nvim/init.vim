scriptencoding utf-8

lua << EOF
-- Bootstrap lazy.nvim.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

plugin_spec = {}
post_plugin_callbacks = {}
function use(spec)
	table.insert(plugin_spec, spec)
end
function post_plugins(fn)
	table.insert(post_plugin_callbacks, fn)
end
EOF

runtime ftplugin/man.vim

let $CONFIGPATH = stdpath('config')

source $CONFIGPATH/core.vim
source $CONFIGPATH/utils.vim
source $CONFIGPATH/syntax.vim
source $CONFIGPATH/highlight.vim
source $CONFIGPATH/lsp.vim
source $CONFIGPATH/statusline.vim


""" Other mappings.

" Copy to tmux.
vnoremap <leader>y :Tyank<CR>

" Easy-Align
"xmap ga <Plug>(EasyAlign)

" Capitalize the last inserted text
function! Capitalize_and_return()
	normal `[v`]gU`]
	silent s/-/_/
	normal ``a
endfunction

" Usable from <C-o>
nnoremap <leader>c :normal `[v`]gU`]a<CR>
" Usable from insert mode, and replaces - with _
inoremap <F3> <C-o>:call Capitalize_and_return()<CR>

let g:ranger_map_keys = 0
nnoremap <leader>f :RangerCurrentDirectory<CR>

" NetRW
nnoremap <leader>fb <Cmd>Explore<CR>


nnoremap ]g <Cmd>lua gitsigns.next_hunk({ preview = true })<CR>
nnoremap [g <Cmd>lua gitsigns.prev_hunk({ preview = true })<CR>
nnoremap gs <Cmd>lua gitsigns.preview_hunk()<CR>

nnoremap <leader>tg <Cmd>Telescope git_files<CR>
nnoremap <leader>tb <Cmd>Telescope buffers<CR>
nnoremap <C-p> <Cmd>lua telescope.builtin.buffers { sort_mru = true }<CR>
nnoremap <C-p> <Cmd>Telescope buffers sort_mru=true<CR>
nnoremap <leader>tm <Cmd>Telescope marks<CR>
nnoremap <leader>tt <Cmd>Telescope tags<CR>
nnoremap <leader>tl <Cmd>Telescope loclist<CR>

lua <<EOF
function _hl_cursor_col()
	vim.wo.cursorcolumn = true
	local function curcol_off()
		vim.wo.cursorcolumn = false
	end
	vim.defer_fn(curcol_off, vim.o.timeoutlen)
end

-- Highlight the cursor's column, briefly
vim.keymap.set("n", "<leader>hh", _hl_cursor_col, {
	desc = "highlight the cursor's column, briefly"
})

function what_indent()
	local lines = {}
	local settings = { "cindent", "autoindent", "smartindent", "indentexpr" }
	for _, setting in ipairs(settings) do
		local line = ""
		local value = vim.o[setting]
		if value == true then
			line = line .. "  " .. setting
		elseif value == false then
			line = line .. "no" .. setting
		else
			line = line .. "  " .. setting .. "=" .. value
			if setting == "indentexpr" and vim.fn.empty(value) == 0 then
				local evaled = vim.fn.eval(value)
				line = line .. "=" .. evaled
			end
		end
		table.insert(lines, line)
	end
	return vim.fn.join(lines, "\n")
end
EOF

function! WhatIndentCmd(bang) abort
	if a:bang == "!"
		lua vim.notify(what_indent())
	else
		echo v:lua.what_indent()
	endif
endfunction

command! -bang WhatIndent call WhatIndentCmd("<bang>")

lua << EOF
-- Text editing.
use {
	-- Python folds.
	'tmhedberg/SimpylFold',
	filetype = "python",
}
use {
	'junegunn/vim-easy-align',
	lazy = true,
}

-- Utilities.
use 'tpope/vim-eunuch'
use {
	'm4xshen/autoclose.nvim',
	opts = {
		options = {
			disable_command_mode = true,
			disable_when_touch = true,
		},
		keys = {
			-- Don't autoclose quotes — single or double — or backticks.
			['"'] = { close = false },
			["'"] = { close = false },
			["`"] = { close = false },
		},
	},
}
use {
	'johmsalas/text-case.nvim',
	-- TODO: nnoremap <leader>gac <Cmd>lua vim.fn.setreg("", '_' .. p.textcase.api.to_camel_case(vim.fn.expand('<cword>')))<CR>
	opts = {
		prefix = "<leader>a"
	},
}
-- lua vim.print((function() local mappings = vim.api.nvim_get_keymap('n'); local filtered = { }; for i, mapping in ipairs(mappings) do if mapping.rhs ~= nil and string.find(mapping.rhs, 'textcase') then table.insert(filtered, mapping); end end return filtered end)())
use 'rbgrouleff/bclose.vim' -- Dependency for ranger.vim
use {
	'francoiscabrol/ranger.vim',
	dependencies = { 'rbgrouleff/bclose.vim' },
}
use 'tpope/vim-tbone' -- :Tyank and :Tput
use {
	'lewis6991/gitsigns.nvim',
	config = function()
		gitsigns = require("gitsigns")
		gitsigns.setup {
			-- Don't fill the signcolumn for untracked files.
			attach_to_untracked = false,
		}
	end,
}
use {
	'akinsho/git-conflict.nvim',
	opts = {},
}
use 'tpope/vim-characterize' -- ga
use 'tpope/vim-abolish'
use 'tpope/vim-obsession'
use 'tpope/vim-fugitive'
use 'gennaro-tedesco/nvim-peekup'
use 'AndrewRadev/bufferize.vim'
use {
	'windwp/nvim-projectconfig',
	opts = { },
}

-- Pickers
--use 'ctrlpvim/ctrlp.vim'
use 'nvim-lua/plenary.nvim' -- Dependency for telescope.
use {
	'nvim-telescope/telescope.nvim',
	dependencies = { 'nvim-lua/plenary.nvim' },
	config = function()
		telescope = require('telescope')
		telescope.setup {}
		telescope.builtin = require('telescope.builtin')
		telescope.sorters = require('telescope.sorters')
		telescope.load_extension("ui-select")
	end,
}
use {
	-- Use telescope as the picker for things like vim.lsp.buf.code_action()
	"nvim-telescope/telescope-ui-select.nvim",
}

-- Display.
use 'dhruvasagar/vim-zoom' -- <C-w>m

-- We don't really like the icons but we're getting tired of plugin stuff just showing question marks
-- and we don't want to worry about overriding it all right now.
use {
	'nvim-tree/nvim-web-devicons',
	opts = {},
}

use {
	'ii14/neorepl.nvim',
	lazy = true,
	cmd = "Repl",
}

use {
	'chentoast/marks.nvim',
	opts = {
		default_mappings = false,
		default_marks = {
			"'", -- position of the latest jump
			"^", -- position of last InsertExit
			".", -- position last change was made
		},
	},
}

--use 'Konfekt/vim-alias'
--use 'thinca/vim-ft-vim_fold'

-- For our convenience, let's create a table that'll have all the main lua modules
-- for each of our plugins, with a normalized key name.
p = {}

vim.api.nvim_create_autocmd("User", {
	pattern = "LazyLoad",
	callback = function(autocmd_event)
		lazy_import_plugin(autocmd_event.data)
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "LazyDone",
	callback = function(autocmd_event)
		for i, lazy_plugin in ipairs(lazy.plugins()) do
			lazy_import_plugin(lazy_plugin.name, lazy_plugin)
		end
	end,
})

lazy = require('lazy')
-- These submodules aren't used here, but are used in the above autocommands,
-- and are also handy for convenience.
lazy.core = {
	config = require("lazy.core.config"),
	util = require("lazy.core.util"),
	loader = require("lazy.core.loader"),
}

lazy.setup(plugin_spec, {
	install = {
		missing = true, -- Default
		colorscheme = { "solorized8_grey" },
	},
})

-- Let us use :Lazy commands right after startup, like for `nvim -c`.
require('lazy.view.commands').setup()

-- With the below autocommand, will record Neovim's startup time.
--function record()
--	io.open("/tmp/stats.txt", "w+"):write(tostring(require("lazy").stats().startuptime) .. "\n")
--	vim.cmd("q")
--end

EOF

"autocmd User VeryLazy lua record()

" vim:textwidth=0
