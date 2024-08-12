" cSpell:enableCompoundWords

"
" Configuration related to LSP and LSP-like stuff, such as autocompletion and linting.
"


""" Completion

function! CheckBackspace() abort
	let l:col = col('.') - 1
	return !col || getline('.')[col - 1]  =~# '\s'
endfunction

set completeopt=menu,menuone,preview,noselect,noinsert

inoremap <expr> <tab> pumvisible() ? "\<C-n>" : "\<tab>"
inoremap <expr> <S-tab> pumvisible() ? "\<C-p>" : "\<S-tab>"
" Hm, Eunich is messing this up
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
inoremap <C-Space> <C-x><C-o>
"inoremap <expr> <C-e> pumvisible() ? "\<C-e>" : v:lua.close_all_float()

nnoremap <leader><BS> <Cmd>:pclose<CR>
nnoremap <leader>xx :Trouble <C-i>
nnoremap <leader>xc <Cmd>TroubleToggle<CR>

" LSP-related highlights.
highlight! NotifyBackground guibg=#1b1b1b


if exists('g:tagbar_sort')
	unlet g:tagbar_sort
endif

nnoremap <leader>gr <Cmd>Telescope lsp_references<CR>

function! JumpDeclaration() abort
	if exists('b:lsp_client')
		call v:lua.vim.lsp.buf.declaration()
	elseif !empty(taglist(expand('<cword>')))
		echo "jumped to tag"
		normal! g
	else
		normal! gD
	endif
endfunction

function! JumpDefinition() abort
	if exists('b:lsp_client')
		call v:lua.vim.lsp.buf.definition()
	elseif !empty(taglist(expand('<cword>')))
		echo "jumped to tag"
		normal! g
	else
		normal! gD
	endif
endfunction

nnoremap gD <Cmd>call JumpDeclaration()<CR>
nnoremap gd <Cmd>call JumpDefinition()<CR>
nnoremap K <Cmd>call v:lua.vim.lsp.buf.hover()<CR>
nnoremap <CR> <Cmd>call v:lua.vim.lsp.buf.hover()<CR>
nnoremap gi <Cmd>Telescope lsp_implementations<CR>
inoremap <C-k> <Cmd>call v:lua.vim.lsp.buf.signature_help()<CR>
"lua vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help)
nnoremap <leader>D <Cmd>Telescope lsp_type_definitions<CR>
nnoremap <leader>a <Cmd>call v:lua.vim.lsp.buf.code_action()<CR>
nnoremap <leader>tw <Cmd>Telescope lsp_dynamic_workspace_symbols<CR>
nnoremap <leader>e <Cmd>call v:lua.vim.diagnostic.open_float()<CR>
nnoremap <leader>td <Cmd>Telescope diagnostics<CR>
nnoremap <leader>tr <Cmd>Telescope lsp_references<CR>
nnoremap [d <Cmd>call v:lua.diagnostic.goto_prev()<CR>
nnoremap ]d <Cmd>call v:lua.diagnostic.goto_next()<CR>
nnoremap <leader>h <Cmd>v:lua.lsp.buf.document_highlight()<CR>
nnoremap <leader>c <Cmd>v:lua.lsp.buf.clear_references()<CR>
nnoremap <leader>sh <Cmd>ClangdSwitchSourceHeader<CR>

lua << EOF

function close_all_float()
	local wins = vim.api.nvim_list_wins()
	for _, winid in ipairs(wins) do
		local win = vim.api.nvim_win_get_config(winid)
		if win.relative ~= "" then
			vim.api.nvim_win_close(winid, false)
		end
	end
end

vim.keymap.set('i', '<C-f>', close_all_float)

vim.lsp.log = require('vim.lsp.log')
vim.lsp.protocol = require('vim.lsp.protocol')
function lsp_format(...)
	return ...
end
vim.lsp.log.set_format_func(lsp_format)

-- We are using lsp_lines for virtual text instead.
vim.diagnostic.config {
	virtual_text = false,
	virtal_lines = false,
}

lsp_filetypes = {
	"vim",
	"c",
	"cpp",
	"rust",
	"zig",
	"python",
	"swift",
	"java",
	"html",
	"javascript",
	"typescript",
	"lua",
	"nix",
}

lsp_opts = {
	clangd = {
		trace = {
			server = "verbose"
		},
		cmd = {
			"clangd",
			"--rename-file-limit=100",
		},
	},
	lua_ls = {
		diagnostics = {
			globals = { 'vim' },
		},
		workspace = {
			library = vim.api.nvim_get_runtime_file("", true),
		},
	},
}

lspconfig_modules = {
	vim = "vimls",
	c = "clangd",
	cpp = "clangd",
	python = "pyright",
	java = "jdtls",
	html = "html",
	swift = "sourcekit",
	--javascript = "tsserver",
	--typescript = "tsserver",
	javascript = "denols",
	typescript = "denols",
	lua = "lua_ls",
	nix = "nil_ls",
	zig = "zls",
}

-- Create autocommands to call setup() on the corresponding module when that filetype is detected.
for i, filetype in ipairs(lsp_filetypes) do
	local augroup_name = "LspConfig_" .. filetype
	local group = vim.api.nvim_create_augroup(augroup_name, {})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { filetype },
		desc = "Autocommand for LSP config for " .. filetype,
		once = true,
		callback = function(event)
			local submodule_name = lspconfig_modules[filetype]
			if submodule_name ~= nil then
				local submodule = require("lspconfig")[submodule_name]
				if submodule ~= nil then
					-- TODO: allow server-specific config.
					vim.notify("lspconfig." .. submodule_name .. ".setup()", vim.log.levels.TRACE)
					local opts = lsp_opts[submodule_name] or {}
					submodule.setup(opts)
				end
			end

			-- Now that our LSP setup is done, run the autostart detection code.
			-- FIXME: figure out a server-agnostic way to do this.
			if submodule_name == "clangd" then
				lspconfig.clangd.manager:try_add(event.buffer)
			end
		end,
	})
end

function on_lsp_attach(bufnr, client_id)
	local client = vim.lsp.get_client_by_id(client_id)
	vim.b[bufnr].lsp_client = client_id
	vim.notify(string.format("LSP %s attached to %d", client.name or "<unknown>", bufnr))

	require('lsp_compl').attach(client, bufnr)

	if client.name == 'nil_ls' then
		client.server_capabilities.semanticTokensProvider = nil
	end

	vim.api.nvim_create_autocmd("DiagnosticChanged", {
		buffer = bufnr,
		callback = function()
			vim.diagnostic.setqflist({ open = false })
		end,
	})

	require("lsp_basics").make_lsp_commands(client, bufnr)

	-- Make `vim.lsp.log` available for our convenience.
	--if vim.lsp.log == nil then
	--	vim.lsp.log = require("vim.lsp.log")
	--end

	-- The LSP-provided tagfunc causes more problems than it solves.
	-- It takes precedence over tag files, and if we *have* tag files in a workspace where we have LSP,
	-- then there's probably something the tags are giving us that LSP is not.
	vim.bo.tagfunc = ""
end

local augroup = vim.api.nvim_create_augroup("LspMappings", {})
vim.api.nvim_create_autocmd("LspAttach", {
	group = augroup,
	callback = function(args)
		on_lsp_attach(args.buf, args.data.client_id)
	end,
})

function client_by_name(name)
	if type(name) ~= "string" then
		error("client_by_name(name): name must be a string")
	end

	for _i, client in ipairs(vim.lsp.get_active_clients()) do
		if client.name == name then
			return client
		end
	end
end

function lsp_active_client_names()
	names = {}
	for _i, client in ipairs(vim.lsp.get_active_clients()) do
		table.insert(names, client.name)
	end
	return names
end

vim.api.nvim_create_user_command(
	"LspAttachClient",
	function(args)
		vim.lsp.buf_attach_client(0, client_by_name(args.args).id)
	end,
	{
		nargs = 1,
	}
)

EOF

function! SetupFormatOnSave(buffer) abort
	augroup FormatOnSave
		autocmd! BufWritePre a:buffer lua vim.lsp.buf.format({ async = false })
	augroup END
endfunction
command! FormatOnSave call SetupFormatOnSave("<buffer>")

" cSpell: disable
lua << EOF
use {
	'neovim/nvim-lspconfig',
	ft = lsp_filetypes,
	config = function()
		lspconfig = require("lspconfig")
	end,
}
use {
	'rcarriga/nvim-notify',
	config = function()
		vim.notify = require("notify")
	end,
	-- Setup after high priority stuff, but before lspconfig.
	priority = 60,
}
use {
	'mfussenegger/nvim-lsp-compl',
	event = 'LspAttach',
}
-- Make LSP stuff for Neovim's Lua work correctly.
use {
	'folke/neodev.nvim',
	ft = { "vim", "lua" },
	opts = { },
}
use { 'nanotee/nvim-lsp-basics', event = "LspAttach" }
use { 'weilbith/nvim-code-action-menu', event = "LspAttach" }
use {
	'dgagn/diagflow.nvim',
	event = 'LspAttach',
	opts = { },
}
use { 'nanotee/nvim-lsp-basics', lazy = true }
--use { 'weilbith/nvim-code-action-menu', lazy = true }
use { 'tamago324/nlsp-settings.nvim', event = "LspAttach" }
use {
	'simrat39/rust-tools.nvim',
	lazy = true,
	ft = "rust",
	opts = {
		cmd = { "rust_analyzer" },
		server = {
			standalone = true,
		},
	},
}
use { 'simrat39/symbols-outline.nvim', event = "LspAttach" }
use { 'https://git.sr.ht/~whynothugo/lsp_lines.nvim', event = "LspAttach" }
-- FIXME: this plugin is no longer maintained.
use { 'folke/lsp-colors.nvim', event = "LspAttach" }
use { 'https://git.sr.ht/~p00f/clangd_extensions.nvim', ft = { "c", "cpp" } }
use {
	'folke/trouble.nvim',
	event = "LspAttach",
	opts = {
		icons = false,
	},
}
use {
  "ray-x/lsp_signature.nvim",
  event = "VeryLazy",
  opts = {
	toggle_key = '<C-s>',
	floating_window_above_cur_line = true,
	fix_pos = true,
  },
  config = function(_, opts) require'lsp_signature'.setup(opts) end
}
EOF
