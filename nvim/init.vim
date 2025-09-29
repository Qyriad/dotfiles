scriptencoding utf-8

lua << EOF

qyriad = require('qyriad')

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
source $CONFIGPATH/lsp.lua
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
"nnoremap <leader>c :normal `[v`]gU`]a<CR>
" Usable from insert mode, and replaces - with _
inoremap <F3> <C-o>:call Capitalize_and_return()<CR>

let g:ranger_map_keys = 0
nnoremap <leader>f :RangerCurrentDirectory<CR>

" NetRW
nnoremap <leader>fb <Cmd>Explore<CR>


"nnoremap ]g <Cmd>lua gitsigns.nav_hunk('next', { preview = true })
nnoremap ]g <Cmd>Gitsigns nav_hunk next preview=true<CR>
"nnoremap [g <Cmd>lua gitsigns.nav_hunk('prev', { preview = true })
nnoremap [g <Cmd>Gitsigns nav_hunk prev preview=true<CR>
"nnoremap gs <Cmd>lua gitsigns.preview_hunk()<CR>
nnoremap gs <Cmd>Gitsigns preview_hunk<CR>
nnoremap <leader>ga <Cmd>Gitsigns stage_hunk greedy=false<CR>
nnoremap <leader>gb <Cmd>Gitsigns blame_line<CR>

nnoremap <leader>tg <Cmd>Telescope live_grep<CR>
nnoremap <leader>tf <Cmd>Telescope git_files<CR>
nnoremap <leader>tF <Cmd>Telescope find_files<CR>
"nnoremap <leader>tb <Cmd>Telescope buffers<CR>
lua <<EOF
vim.keymap.set("n", "<leader>tb", "", {
	callback = function()
		p.telescope.builtin.buffers {
			prompt_title = "select buffer",
			attach_mappings = function(_, map)
				map({ "n" }, "dd", telescope.actions.delete_buffer)
				local extend_default_mappings = true
				return extend_default_mappings
			end,
		}
	end,
})
EOF
"nnoremap <C-p> <Cmd>lua telescope.builtin.buffers { sort_mru = true }<CR>
nnoremap <C-p> <Cmd>Telescope buffers sort_mru=true<CR>
nnoremap <leader>tm <Cmd>Telescope marks<CR>
nnoremap <leader>tt <Cmd>Telescope tags<CR>
nnoremap <leader>tl <Cmd>Telescope loclist<CR>
nnoremap <leader>tj <Cmd>Telescope jumplist<CR>

"augroup TelescopeMappings
"
"augroup END

" Fix buffer names that should be relative paths.
function! FixName() abort
	if &l:modifiable != v:true
		throw "buffer must be modifiable"
	endif

	lua vim.cmd.file(vim.fn.expand("%:."))
	edit!
endfunction
command! Fixname call FixName()

function! FixNameIfNeeded() abort
	if &l:modifiable != v:true
		return
	endif

	let l:expanded = expand("%:.")
	if l:expanded != bufname()
		execute "keepalt file " .. l:expanded
	endif
endfunction

"augroup AutoFixName
"	autocmd! BufReadPost * call FixNameIfNeeded()
"augroup END

"command! FixName call FixName()

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

-- Ughhh autoclose.nvim is overriding this.
--vim.keymap.set("i", "<C-h>", _hl_cursor_col, {
--	desc = "highlight the cursor's column, briefly",
--})

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
			-- Don't autoclose square brackets either.
			["["] = { close = false },
			--["<CR>"] = { close = false },
		},
	},
	config = function(plugin, opts)
		-- HACK: autoclose overrides all our other <CR> mappings (eunuch, pum-accept).
		-- But stupid private functions mean we can't just `require('autoclose.nvim').autoclose_cr()
		-- or anything.
		-- So here we run autoclose's normal setup, and then restore the original mapping, but save
		-- the autoclose mapping in our plugin shortcut global `p.autoclose`.
		local pl = lazy.core.config.plugins['autoclose.nvim']
		local main_name = lazy.core.loader.get_main(plugin)
		local main = require(main_name)

		-- Get the <CR> mapping before calling setup().
		local existing_cr = vim.fn.maparg('<CR>', 'i', false, true)
		p.autoclose = qyriad.tbl_override(p.autoclose, { previous_cr = existing_cr })

		-- Let autoclose mess with things.
		main.setup(opts)


		-- Save the mapping information from autoclose.
		p.autoclose.new_cr = vim.fn.maparg('<CR>', 'i', false, true)

		-- And then restore the original mapping.
		if not vim.tbl_isempty(existing_cr) then
			vim.fn.mapset(existing_cr)
		end
	end,
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
			-- Higher priority than MarkSigns.
			sign_priority = 11,
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
use 'tpope/vim-scriptease'
use 'gennaro-tedesco/nvim-peekup'
use 'AndrewRadev/bufferize.vim'
use {
	'windwp/nvim-projectconfig',
	opts = { },
}

-- Pickers
--use 'ctrlpvim/ctrlp.vim'
-- Dependency for telescope.
use {
	'nvim-lua/plenary.nvim',
	config = function()
		plenary = require('plenary')
	end,
}
use {
	'nvim-telescope/telescope.nvim',
	dependencies = { 'nvim-lua/plenary.nvim' },
	config = function()
		telescope = require('telescope')
		telescope.setup {
			--defaults = {
			--
			--}
			--create_layout = function(picker)
			--end,
		}
		telescope.builtin = require('telescope.builtin')
		telescope.actions = require('telescope.actions')
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
		-- Sure, let's try it.
		default_mappings = true,
		builtin_marks = {
			"'", -- position of the latest jump
			"^", -- position of last InsertExit
			".", -- position last change was made
		},
	},
}

use {
	'walkersumida/fusen.nvim',
	event = "VimEnter",
	opts = {
		keymaps = {
			add_mark = '<leader>me',
			clear_mark = '<leader>mc',
			next_mark = '<leader>]m',
			prev_mark = '<leader>[m',
		},
		annotation_display = {
			mode = 'both',
		},
		sign_priority = 100,
	},
}
vim.cmd[[
nnoremap <leader>ml <Cmd>Telescope fusen marks<CR>
]]

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
