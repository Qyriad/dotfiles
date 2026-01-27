vim.cmd[[
"
" Configuration related to LSP and LSP-like stuff, such as autocompletion and linting.
"


""" Completion

function! CheckBackspace() abort
	let l:col = col('.') - 1
	return !col || getline('.')[col - 1]  =~# '\s'
endfunction

set completeopt=menu,menuone,popup,noselect,noinsert

if has("nvim-0.11")
	set winborder=rounded
endif

inoremap <expr> <tab> pumvisible() ? "\<C-n>" : "\<tab>"
inoremap <expr> <S-tab> pumvisible() ? "\<C-p>" : "\<S-tab>"
lua <<EOF
-- Make autoclose.nvim work with the other <CR> mappings we have.
function handle_cr()
	local autoclose_handler = vim.tbl_get(_G.p or { }, 'autoclose', 'new_cr', 'callback')
	if autoclose_handler then
		return vim.keycode(autoclose_handler())
	end
	return vim.keycode("<CR>")
end
EOF
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : v:lua.handle_cr()
inoremap <C-Space> <C-x><C-o>
"inoremap <expr> <C-e> pumvisible() ? "\<C-e>" : v:lua.close_all_float()

nnoremap <leader><BS> <Cmd>:pclose<CR>
nnoremap <leader>xx :Trouble <C-i>
nnoremap <leader>xc <Cmd>TroubleToggle<CR>

" LSP-related highlights.
highlight! NotifyBackground guibg=#1b1b1b

command! LspClients echo v:lua.qyriad.lsp_iter_clients()


if exists('g:tagbar_sort')
	unlet g:tagbar_sort
endif

nnoremap <leader>gr <Cmd>Telescope lsp_references<CR>

function! JumpDeclaration() abort
	if exists('b:lsp_client')
		autocmd BufReadPost * ++once Fixname
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
		autocmd BufReadPost * ++once Fixname
		Telescope lsp_definitions
	elseif !empty(taglist(expand('<cword>')))
		echo "jumped to tag"
		normal! g
	else
		normal! gD
	endif
endfunction

function! JumpImplementations() abort
	autocmd BufReadPost * ++once Fixname
	Telescope lsp_implementations
endfunction

nnoremap gD <Cmd>call JumpDeclaration()<CR>
nnoremap gd <Cmd>call JumpDefinition()<CR>
nnoremap K <Cmd>call v:lua.vim.lsp.buf.hover()<CR>
nnoremap <CR> <Cmd>call v:lua.vim.lsp.buf.hover()<CR>
nnoremap gi <Cmd>call JumpImplementations()<CR>
inoremap <C-k> <Cmd>call v:lua.vim.lsp.buf.signature_help()<CR>
"lua vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help)
nnoremap <leader>D <Cmd>Telescope lsp_type_definitions<CR>
nnoremap <leader>tT <Cmd>Telescope lsp_type_definitions<CR>
nnoremap <leader>a <Cmd>call v:lua.vim.lsp.buf.code_action()<CR>
nnoremap <leader>ca <Cmd> call v:lua.vim.lsp.buf.code_action()<CR>
nnoremap <leader>tw <Cmd>Telescope lsp_dynamic_workspace_symbols<CR>
nnoremap <leader>e <Cmd>call v:lua.vim.diagnostic.open_float()<CR>
nnoremap <leader>td <Cmd>Telescope diagnostics<CR>
nnoremap <leader>tr <Cmd>Telescope lsp_references<CR>
lua vim.g.diagnostic_severity = { min = vim.diagnostic.severity.WARN }
nnoremap [d <Cmd>call v:lua.vim.diagnostic.goto_prev({ "severity": g:diagnostic_severity })<CR>
nnoremap ]d <Cmd>call v:lua.vim.diagnostic.goto_next({ "severity": g:diagnostic_severity })<CR>
nnoremap <leader>h <Cmd>call v:lua.vim.lsp.buf.document_highlight()<CR>
"nnoremap <leader>c <Cmd>call v:lua.vim.lsp.buf.clear_references()<CR>
" 'Symbol rename'
nnoremap <leader>sr <Cmd>call v:lua.vim.lsp.buf.rename()<CR>
nnoremap <leader>sh <Cmd>ClangdSwitchSourceHeader<CR>

" NOTE: no explicit binding for formatting. gq will use `formatexpr`.

" 'Notification dismiss'.
nnoremap <leader>nd <Cmd>lua p.notify.dismiss({ pending = true })<CR>

function! DiagnosticsComplete(arglead, cmdline, cursorpos) abort
	return ["error", "warn", "info", "hint"]
endfunction

"command! -complete=customlist,DiagnosticsComplete -nargs=? Diagnostics call v:lua._cmd_diagnostics_impl(<f-args>)
]]

function lsp_quiet()
	-- This function is called in map-expr context, where we can't change text in
	-- buffers. The signature floating window is also a buffer, so that applies.
	if vim.fn.pumvisible() == 1 then
		return vim.keycode('<C-e>')
	end
	pcall(function() vim.defer_fn(p.lspsignature.toggle_float_win, 10) end)
	return ""
	--return vim.keycode[[<Ignore>]]
end
-- `help i_CTRL-E`, by default it inserts the character that is in the same position as the cursor one line below.
-- Not the most useful.
vim.keymap.set('i', '<C-e>', '', {
	callback = lsp_quiet,
	expr = true,
	desc = "Close LSP popup and floating windows",
})

if not vim.fn.has("nvim-0.11.0") then
	vim.keymap.set('i', '<C-s>', vim.lsp.buf.signature_help, { })
end

vim.lsp.log = require('vim.lsp.log')
vim.lsp.protocol = require('vim.lsp.protocol')
vim.lsp.set_log_level(vim.lsp.log_levels.INFO)

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
	'make',
}

local qyriad = require('qyriad')
vim.lsp.config('*', qyriad.nested_tbl {
	root_markers = { '.git' },

	trace = 'messages',

	-- I hate snippets.
	['capabilities.textDocument.completion.completionItem.snippetSupport'] = false,
})

local lsp_modules = {
	'rust-analyzer',
	'vimls',
	'luals',
	'clangd',
	'nil',
	'mesonlsp',
	'basedpyright',
	'taplo',
	'autotools',
	'tsgo',
}
local req_no_config = setmetatable({ }, { __index = table })
local req_no_exe = setmetatable({ }, { __index = table })
for _, modname in ipairs(lsp_modules) do
	local config = vim.lsp.config[modname]
	if not config then
		req_no_config:insert(modname)
	else
		local cmd = vim.is_callable(config.cmd) and config.cmd() or config.cmd
		local exe = cmd[1]
		if vim.fn.executable(exe) ~= 1 then
			req_no_exe:insert(modname)
		end
	end
end

if #req_no_config > 0 then
	req_no_config = string.format([['%s']], vim.iter(req_no_config):join(", '"))
	vim.notify(string.format("LSP: requested but no config: %s", req_no_config), vim.log.levels.WARN)
end
if #req_no_exe > 0 then
	req_no_exe = string.format([['%s']], vim.iter(req_no_exe):join(", '"))
	vim.notify(string.format("LSP: requested but no executable: %s", req_no_exe), vim.log.levels.WARN)
end
--req_no_exe:foreachi(function(modname)
--	vim.notify(string.format("LSP '%s' requested but executable '%s' not found", modname, exe), vim.log.levels.WARN)
--end)

vim.lsp.enable(lsp_modules)

vim.diagnostic.config({
	signs = {
		severity = vim.g.diagnostic_severity,
	},
})

--lsp_vim_capabilities = vim.lsp.protocol.make_client_capabilities()

clients = {}

vim.cmd[[
augroup DiagnosticToQfList
	autocmd! DiagnosticChanged * lua vim.diagnostic.setqflist({ open = false })
augroup END
]]

last_completion_item = { }

local Kind = vim.lsp.protocol.CompletionItemKind
LspComplKindAbbr = {
	[Kind.Text] = "TXT",
	[Kind.Method] = "MTH",
	[Kind.Function] = "FN",
	[Kind.Constructor] = "CON",
	[Kind.Field] = "FLD",
	[Kind.Variable] = "VAR",
	[Kind.Class] = "CLS",
	[Kind.Interface] = "INT",
	[Kind.Module] = "MOD",
	[Kind.Property] = "PROP",
	[Kind.Unit] = "UNIT",
	[Kind.Value] = "VALUE",
	[Kind.Enum] = "ENUM",
	[Kind.Keyword] = "KEY",
	[Kind.Snippet] = "SNIPPET",
	[Kind.Color] = "COLOR",
	[Kind.File] = "FILE",
	[Kind.Reference] = "REF",
	[Kind.Folder] = "DIR",
	[Kind.EnumMember] = "KIND",
	[Kind.Constant] = "CONST",
	[Kind.Struct] = "CLS",
	[Kind.Event] = "EVNT",
	[Kind.Operator] = "OP",
	[Kind.TypeParameter] = "<PARAM>",
}
Kind = nil

---@param item vim.lsp.CompletionItem
vim.g.lsp_completion_convert_func = function(item)
	vim.b.last_completion_item = item
	local kind = LspComplKindAbbr[item.kind] or vim.lsp.protocol.SymbolKind[item.kind] or item.kind
	return {
		kind = kind,
	}
end

function on_lsp_attach(bufnr, client_id)
	local client = assert(vim.lsp.get_client_by_id(client_id))
	vim.b[bufnr].lsp_client = client_id
	clients[client_id] = client
	clients[client.name] = client
	vim.notify(string.format("LSP %s attached to %d", client.name or "<unknown>", bufnr))

	require("lsp_basics").make_lsp_commands(client, bufnr)

	-- The LSP-provided tagfunc causes more problems than it solves.
	-- It takes precedence over tag files, and if we *have* tag files in a workspace where we have LSP,
	-- then there's probably something the tags are giving us that LSP is not.
	vim.bo.tagfunc = ""

	--vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })

	--if client.name == 'nil_ls' then
	--	client.server_capabilities.semanticTokensProvider = nil
	--end
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


vim.cmd[[
function! SetupFormatOnSave(buffer) abort
	let b:format_on_save = v:true
	augroup FormatOnSave
		autocmd! BufWritePre <buffer=a:buffer> lua vim.lsp.buf.format({ async = false })
	augroup END
endfunction
command! FormatOnSave call SetupFormatOnSave("<buffer>")

function! StopFormatOnSave(buffer) abort
	let b:format_on_save = v:false
	augroup FormatOnSave
		autocmd! BufWritePre <buffer=a:buffer>
	augroup END
endfunction
command! NoFormatOnSave call StopFormatOnSave("<buffer>")
]]

--use {
--	'neovim/nvim-lspconfig',
--	ft = lsp_filetypes,
--	config = function()
--		lspconfig = require("lspconfig")
--	end,
--}
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
--use {
--	'folke/neodev.nvim',
--	ft = { "vim", "lua" },
--	opts = { },
--}
use {
	"folke/lazydev.nvim",
	ft = { "vim", "lua" },
	opts = {
		library = {
			{ path = "luavit-meta/library", words = { "vim%.uv" } },
		},
	},
}
use {
	-- vim.uv typings
	"Bilal2453/luvit-meta",
	ft = { "vim", "lua" },
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
--use { 'tamago324/nlsp-settings.nvim', event = "LspAttach" }
---@type rustaceanvim.Opts
vim.g.rustaceanvim = {
	cmd = { "rust_analyzer" },
	settings = {
		["rust-analyzer"] = {
			inlayHints = {
				maxLength = 5,
			},
		},
	},
}
--use {
--	"mrcjkb/rustaceanvim",
--	lazy = false,
--	--ft = "rust",
--}
use { 'simrat39/symbols-outline.nvim', event = "LspAttach" }
--use { 'https://git.sr.ht/~whynothugo/lsp_lines.nvim', event = "LspAttach" }
use { 'https://git.sr.ht/~p00f/clangd_extensions.nvim', ft = { "c", "cpp" } }
--use {
--	'folke/trouble.nvim',
--	event = "LspAttach",
--	opts = {
--		icons = false,
--	},
--}
use {
  "ray-x/lsp_signature.nvim",
  event = "LspAttach",
  opts = {
	toggle_key_flip_floatwin_setting = true,
	floating_window_above_cur_line = true,
	fix_pos = true,
  },
  config = function(_, opts) require('lsp_signature').setup(opts) end
}
use {
	'mparq/lsptrace.nvim',
}
