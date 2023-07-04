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
function lsp_on_attach(client, bufnr)
	vim.lsp.set_log_level("info")

	vim.notify("Attaching!")

	local bufopts = { noremap = true, buffer = bufnr }

	local mappings = {
		{ 'gD', vim.lsp.buf.declaration },
		{ 'gd', vim.lsp.buf.definition },
		{ 'K',  vim.lsp.buf.hover },
		{ '<CR>',  vim.lsp.buf.hover },
		{ 'gi', vim.lsp.buf.implementation },
		{ '<C-k>', vim.lsp.buf.signature_help },
		{ '<leader>D', vim.lsp.buf.type_definition },
		{ '<leader>a', code_action_menu.open_code_action_menu },
		-- Diagnostics.
		{ '<leader>e', vim.diagnostic.open_float }, -- 'e' for 'error'
		{ '[d', vim.diagnostic.goto_prev },
		{ ']d', vim.diagnostic.goto_next },
	}

	for i, item in ipairs(mappings) do
		local keys = item[1]
		local func = item[2]
		--print("Mapping " .. keys)
		vim.keymap.set('n', keys, func, bufopts)
	end

	vim.api.nvim_create_autocmd('DiagnosticChanged', {
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

	lsp_basics.make_lsp_commands(client, bufnr)
end
EOF


" cSpell: disable
lua << EOF
local use = packer.use
use {
	'neovim/nvim-lspconfig',
	--after = {'nvim-cmp', 'cmp-nvim-lsp'},
	config = function()
		lspconfig = require('lspconfig')
	end
}
use 'hrsh7th/cmp-nvim-lsp'
--use 'hrsh7th/vim-vsnip'
use {
	'L3MON4D3/LuaSnip',
	config = function()
		luasnip = require('luasnip')
	end
}
use {
	'hrsh7th/nvim-cmp',
	config = function()
		local cmp = require('cmp')
		local lspconfig = require('lspconfig')
		lsps = {
			-- rust_analyzer is setup by rust-tools.nvim.
			'vimls',
			'clangd',
			'pyright',
			'jdtls',
		}

		cmp.setup {
			snippet = {
				expand = function(args)
					require('luasnip').lsp_expand(args.body)
				end
			},
			preselect = cmp.PreselectMode.Item,
			mapping = {
				['<C-Space'] = cmp.mapping.complete(),
				['<Tab>'] = cmp.mapping.select_next_item(),
				['<S-Tab>'] = cmp.mapping.select_prev_item(),
				['<CR>'] = cmp.mapping.confirm({ select = false }),
			},
			sources = cmp.config.sources {
				{ name = 'nvim_lsp' },
				{ name = 'buffer' },
			},
		}

		local cap = require('cmp_nvim_lsp').default_capabilities()

		-- We really, really dislike snippets.
		cap.textDocument.completion.completionItem.snippetSupport = false

		severity = {
			"error",
			"warn",
			"info",
			"info", -- Map hint to info
		}

		for i, lsp in ipairs(lsps) do
			local lsp_name = ''
			local lsp_args = { }
			lsp_args.handlers = {
				["window/showMessage"] = function(err, meth, params, client_id)
					vim.notify(meth.message, severity[params.type])
				end,
			}
			if type(lsp) == 'string' then
				lsp_name = lsp
				lsp_args = {
					on_attach = lsp_on_attach,
					capabilities = cap,
				}
			else
				local array, lsp_args = separate(lsp)
				lsp_name = array[1]
				lsp_args.on_attach = lsp_on_attach
				lsp_args.capabilities = cap
			end
			lspconfig[lsp_name].setup(lsp_args)
		end
	end
}
use {
	'tamago324/nlsp-settings.nvim',
	config = function()
		require('nlspsettings').setup {}
	end,
}
--use 'hrsh7th/cmp-buffer'
--use 'hrsh7th/cmp-path'
use {
	'simrat39/rust-tools.nvim',
	config = function()
		rust_tools = require("rust-tools")
		rust_tools.setup {
			server = {
				on_attach = lsp_on_attach,
			},
		}
	end,
}

use {
	'simrat39/symbols-outline.nvim',
	config = function()
		symbols_outline = require("symbols-outline")
	end,
}

use {
	'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
	config = function()
		lsp_lines = require("lsp_lines")
		lsp_lines.setup {}
	end,
}

-- FIXME: This plugin is no longer maintained.
use {
	'folke/lsp-colors.nvim',
	config = function()
		lsp_colors = require("lsp-colors")
	end,
}

use {
	'folke/trouble.nvim',
	config = function()
		trouble = require("trouble")
		trouble.setup {
			icons = false,
		}
	end,
}

use {
	'nanotee/nvim-lsp-basics',
	config = function()
		lsp_basics = require("lsp_basics")
	end,
}

use {
	'weilbith/nvim-code-action-menu',
	config = function()
		code_action_menu = require("code_action_menu")
	end,
}

use {
	'rcarriga/nvim-notify',
	config = function()
		vim.notify = require("notify")
	end,
}

use {
	'mrded/nvim-lsp-notify',
	config = function()
		lsp_notify = require("lsp-notify")
		lsp_notify.setup {
			stages = "slide",
		}
	end,
}
EOF
