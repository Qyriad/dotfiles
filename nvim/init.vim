scriptencoding utf-8

lua << EOF

qyriad = require('qyriad')

vim._comment = qyriad.tbl_override(vim._comment, require('vim._comment'))

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

" On Nix-managed systems we don't usually have a compiler in our PATH,
" *unless* we're in a dev shell.
" If we have some existing `cc`, we don't want to fuck with that.
" But if we don't, we'll let Vim access a compiler we have in our Nix systems
" that is not normally in our PATH.
" Among other things, this makes treesitter installs Just Work.
if !executable("cc") && isdirectory("/run/current-system/sw/opt/llvm/bin")
	let $PATH = $PATH .. ":" .. "/run/current-system/sw/opt/llvm/bin"
endif

source $CONFIGPATH/core.vim
source $CONFIGPATH/utils.vim
source $CONFIGPATH/syntax.vim
source $CONFIGPATH/highlight.vim
source $CONFIGPATH/lsp.lua
source $CONFIGPATH/statusline.vim


""" Other mappings.

" Copy to tmux.
vnoremap <leader>y :Tyank<CR>

" Sort visual selection.
vnoremap gs :'<,'>sort u<CR>

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
function! Recd() abort
	cd $PWD
endfunction
command! Recd cd $PWD
nnoremap <leader>rcd <Cmd>Recd<CR>

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

--use 'Konfekt/vim-alias'
--use 'thinca/vim-ft-vim_fold'


-- For our convenience, let's create a table that'll have all the main lua modules
-- for each of our plugins, with a normalized key name.
p = {}

vim.api.nvim_create_autocmd("User", {
	pattern = "LazyLoad",
	callback = function(autocmd_event)
		pcall(lazy_import_plugin, autocmd_event.data)
		--lazy_import_plugin(autocmd_event.data)
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "LazyDone",
	callback = function(autocmd_event)
		for i, lazy_plugin in ipairs(lazy.plugins()) do
			--lazy_import_plugin(lazy_plugin.name, lazy_plugin)
			status, res = pcall(lazy_import_plugin, lazy_plugin.name, lazy_plugin)
			if not status then
				vim.notify(string.format(
					"lazy_import_plugin(%s) failed: %s",
					lazy_plugin.name,
					vim.inspect(res)
				))
			end
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
lazy.util = require('lazy.util')

--lazy.setup(plugin_spec, {
--	install = {
--		missing = true, -- Default
--		--colorscheme = { "solorized8_grey" },
--		colorscheme = { "catppuccin-macchiato" },
--	},
--})
lazy.setup {
	-- Load plugin specs from `nvim/lua/plugins` (...technically from &rtp/lua/plugins but w/e).
	spec = { import = 'plugins' },
	install = { colorscheme = { 'catppuccin-macchiato' } },
	profiling = {
		loader = true,
		require = true,
	},
}

-- Let us use :Lazy commands right after startup, like for `nvim -c`.
require('lazy.view.commands').setup()

-- With the below autocommand, will record Neovim's startup time.
--function record()
--	io.open("/tmp/stats.txt", "w+"):write(tostring(require("lazy").stats().startuptime) .. "\n")
--	vim.cmd("q")
--end

EOF

colorscheme catppuccin-macchiato

"autocmd User VeryLazy lua record()

" vim:textwidth=0
