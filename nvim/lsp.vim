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
" Close the popup menu with <Esc>.
"inoremap <expr> <Esc> coc#pum#visible() ? "\<C-e>" : "\<Esc>"
" Accept the selected completion with <CR>.
"inoremap <expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
" Select the next completion with <Tab>.
"inoremap <expr> <Tab> coc#pum#visible() ? coc#pum#next(1) : CheckBackspace() ? "\<Tab>" : coc#refresh()

" Select the previous completion with <S-Tab>
"inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
"inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" <C-Space> to force open the completion menu.
"inoremap <silent><expr> <C-Space> coc#refresh()


" Non-completion LSP mappings.
"nnoremap <silent> <Return> <Cmd>call CocActionAsync('doHover')<CR>
"nmap <A-Return> <Plug>(coc-definition)
"nmap <A-]> <Plug>(coc-type-definition)
"nmap <A-t> <Plug>(coc-type-definition)
"nmap <A-[> <Plug>(coc-references)
"nmap <A-r> <Plug>(coc-references)

"xmap if <Plug>(coc-funcobj-i)
"omap if <Plug>(coc-funcobj-i)
"xmap af <Plug>(coc-funcobj-a)
"omap af <Plug>(coc-funcobj-a)
"xmap ic <Plug>(coc-classobj-i)
"omap ic <Plug>(coc-classobj-i)
"xmap ac <Plug>(coc-classobj-a)
"omap ac <Plug>(coc-classobj-a)

"nmap [d <Plug>(coc-diagnostic-prev)
"nmap ]d <Plug>(coc-diagnostic-next)
"nmap gds <Plug>(coc-diagnostic-info)

"nmap <leader>gcl <Plug>(coc-codelens-action)
"nmap <leader>a <Plug>(coc-codeaction-cursor)

"vmap <leader>p  <Plug>(coc-format-selected)

"nnoremap <M-p> <Cmd>:CocList commands<CR>
"nnoremap <F5> <Cmd>:CocList<CR>
nnoremap <F3> <Cmd>:CtrlPLine<CR>
nnoremap <F4> <Cmd>:CtrlP<CR>
nnoremap <F6> <Cmd>:CtrlPBuffer<CR>
nnoremap <F9> <Cmd>:TagbarToggle<CR>
nnoremap <leader><BS> <Cmd>:pclose<CR>
nnoremap <leader>xx :Trouble <C-i>
nnoremap <leader>xc <Cmd>TroubleToggle<CR>

"command! CocFloatHide call coc#float#close_all()
"inoremap <C-l> <Cmd>call coc#float#close_all()<CR>
"nnoremap <leader><C-l> <Cmd>call coc#float#close_all()<CR>
"nnoremap <leader><esc> <Cmd>CocFloatHide<CR>
"inoremap <leader><esc> <Cmd>CocFloatHide<CR>


" LSP-related highlights.
" These must be after the `:colorscheme` call in syntax.vim.
highlight! link CocSemComment SpecialComment
highlight! link CocMenuSel PmenuSel
"highlight link ALEErrorSign Error
"highlight link ALEWarningSign Todo
"highlight CocRustChainingHint guifg=grey

highlight! NotifyBackground guibg=#1b1b1b


if exists('g:tagbar_sort')
	unlet g:tagbar_sort
endif


lua << EOF
lsp_filetypes = {
	"vim",
	"c",
	"cpp",
	"rust",
	"python",
	"java",
	"html",
}

lspconfig_modules = {
	vim = "vimls",
	c = "clangd",
	cpp = "clangd",
	python = "pyright",
	java = "jdtls",
	html = "html",
}

-- Create autocommands to call setup() on the corresponding module when that filetype is detected.
for i, filetype in ipairs(lsp_filetypes) do
	local augroup_name = "LspConfig_" .. filetype
	local group = vim.api.nvim_create_augroup(augroup_name, {})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = {filetype},
		callback = function(event)
			local submodule_name = lspconfig_modules[filetype]
			if submodule_name ~= nil then
				local submodule = require("lspconfig")[submodule_name]
				if submodule ~= nil then
					-- TODO: allow server-specific config.
					vim.notify("lspconfig." .. submodule_name .. ".setup()", vim.log.levels.TRACE)
					submodule.setup({
						capabilities = require("coq").lsp_ensure_capabilities({}),
					})
				end
			end
		end,
	})
end

local augroup = vim.api.nvim_create_augroup("LspMappings", {})
vim.api.nvim_create_autocmd("LspAttach", {
	group = augroup,
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)

		local bufopts = { noremap = true, buffer = bufnr }
		local mappings = {
			{ 'gD', vim.lsp.buf.declaration },
			{ 'gd', vim.lsp.buf.definition },
			{ 'K',  vim.lsp.buf.hover },
			{ '<CR>',  vim.lsp.buf.hover },
			{ 'gi', vim.lsp.buf.implementation },
			{ '<C-k>', vim.lsp.buf.signature_help, "i" },
			{ '<leader>D', vim.lsp.buf.type_definition },
			{ '<leader>a', require("code_action_menu").open_code_action_menu },
			-- Diagnostics.
			{ '<leader>e', vim.diagnostic.open_float }, -- 'e' for 'error'
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
		require("coq").Now("-s")
	end,
})

vim.g.coq_settings = {
	clients = {
		snippets = {
			-- Disable warnings about snippets.
			warn = { }
		}
	}
}

EOF

" cSpell: disable
lua << EOF
use { 'neovim/nvim-lspconfig', ft = lsp_filetypes }
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
	ft = lsp_filetypes,
}
use { 'nanotee/nvim-lsp-basics', lazy = true }
use { 'weilbith/nvim-code-action-menu', lazy = true }
use { 'tamago324/nlsp-settings.nvim', event = "LspAttach" }
use {
	'simrat39/rust-tools.nvim',
	ft = "rust",
	opts = {
		cmd = { "rust_analyzer" },
	},
}
use { 'simrat39/symbols-outline.nvim', event = "LspAttach" }
use { 'https://git.sr.ht/~whynothugo/lsp_lines.nvim', event = "LspAttach" }
-- FIXME: this plugin is no longer maintained.
use { 'folke/lsp-colors.nvim', event = "LspAttach" }
use {
	'folke/trouble.nvim',
	event = "LspAttach",
	opts = {
		icons = false,
	},
}
use {
	'mrded/nvim-lsp-notify',
	event = "LspAttach",
	opts = {
		stages = "slide",
	},
}
EOF
