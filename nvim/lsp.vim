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

nnoremap <leader><BS> <Cmd>:pclose<CR>
nnoremap <leader>xx :Trouble <C-i>
nnoremap <leader>xc <Cmd>TroubleToggle<CR>

" LSP-related highlights.
highlight! NotifyBackground guibg=#1b1b1b


if exists('g:tagbar_sort')
	unlet g:tagbar_sort
endif

nnoremap <leader>gr <Cmd>Telescope lsp_references<CR>

lua << EOF

vim.lsp.log = require('vim.lsp.log')
function lsp_format(...)
	return ...
end
vim.lsp.log.set_format_func(lsp_format)

lsp_filetypes = {
	"vim",
	"c",
	"cpp",
	"rust",
	"python",
	"swift",
	"java",
	"html",
	"javascript",
	"typescript",
	"lua",
	"nix",
}

lsp_opts = { }

lspconfig_modules = {
	vim = "vimls",
	c = "clangd",
	cpp = "clangd",
	python = "pyright",
	java = "jdtls",
	html = "html",
	swift = "sourcekit",
	javascript = "tsserver",
	typescript = "tsserver",
	lua = "lua_ls",
	nix = "nil_ls",
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
					opts.capabilities = require("coq").lsp_ensure_capabilities({})
					opts.capabilities.textDocument = {
						completion = {
							completionItem = {
								snippetSupport = false,
							},
						},
					}
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
	vim.notify(string.format("LSP %s attached to %d", client.name or "<unknown>", bufnr))

	local bufopts = { noremap = true, buffer = bufnr }
	local mappings = {
		{ 'gD', vim.lsp.buf.declaration },
		{ 'gd', telescope.builtin.lsp_definitions },
		{ 'K',  vim.lsp.buf.hover },
		{ '<CR>',  vim.lsp.buf.hover },
		{ 'gi', telescope.builtin.lsp_implementations },
		--{ '<C-k>', vim.lsp.buf.signature_help, "i" },
		{ '<leader>D', telescope.builtin.lsp_type_definitions },
		{ '<leader>a', require("code_action_menu").open_code_action_menu },
		-- tw for "telescope workspace"
		{ '<leader>tw', telescope.builtin.lsp_dynamic_workspace_symbols },
		-- Diagnostics.
		{ '<leader>e', vim.diagnostic.open_float }, -- 'e' for 'error'
		{ '<leader>td', telescope_diagnostics },
		{ '<leader>tD', telescope.builtin.diagnostics },
		{ '<leader>tr', telescope.builtin.lsp_references },
		{ '[d', vim.diagnostic.goto_prev },
		{ ']d', vim.diagnostic.goto_next },
		{ '<leader>h', vim.lsp.buf.document_highlight },
		{ '<leader>c', vim.lsp.buf.clear_references },
	}

	for i, mapspec in ipairs(mappings) do
		local lhs = mapspec[1]
		local func = mapspec[2]
		local mode = mapspec[3] or "n"
		vim.keymap.set(mode, lhs, func, bufopts)
	end

	if client.name == "clangd" then
		vim.keymap.set("n", "<leader>sh", vim.cmd.ClangdSwitchSourceHeader)
		require("clangd_extensions.inlay_hints").setup_autocmd()
		require("clangd_extensions.inlay_hints").set_inlay_hints()
	end

	if client.name == 'nil_ls' then
		client.server_capabilities.semanticTokensProvider = nil
	end

	vim.api.nvim_create_autocmd("DiagnosticChanged", {
		buffer = bufnr,
		callback = function()
			vim.diagnostic.setqflist({ open = false })
		end,
	})

	vim.diagnostic.config({
		-- We are using lsp_lines for virtual text instead.
		virtual_text = false,
		virtual_lines = true,
	})

	require("lsp_basics").make_lsp_commands(client, bufnr)
	if vim.g.loaded_coq ~= true then
		require("coq").Now("-s")
		vim.g.loaded_coq = true
	end

	-- Make `vim.lsp.log` available for our convenience.
	if vim.lsp.log == nil then
		vim.lsp.log = require("vim.lsp.log")
	end

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

vim.g.coq_settings = {
	clients = {
		snippets = {
			-- Disable warnings about snippets.
			warn = { }
		},
		buffers = {
			enabled = false,
		},
		tmux = {
			enabled = false,
		},
		tags = {
			enabled = false,
		},
	},
}

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
	'ms-jpq/coq_nvim',
	event = "LspAttach",
	--ft = lsp_filetypes,
}
-- Make LSP stuff for Neovim's Lua work correctly.
use {
	'folke/neodev.nvim',
	opts = { },
}
use { 'nanotee/nvim-lsp-basics', lazy = true }
use { 'weilbith/nvim-code-action-menu', lazy = true }
use { 'tamago324/nlsp-settings.nvim', event = "LspAttach" }
use {
	'simrat39/rust-tools.nvim',
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
  opts = {},
  config = function(_, opts) require'lsp_signature'.setup(opts) end
}
EOF
