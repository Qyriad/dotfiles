if #vim.fn.globpath(vim.o.runtimepath, 'lua/treesitter-context') > 0 then
	require("treesitter-context").setup {
		enable = false,
	}
end

-- Hyphen-minus is an identifier character in Nix!
vim.opt_local.iskeyword:append("-")
-- Stop automatically dedendenting "in".
vim.opt_local.indentkeys:remove("0=in")
vim.opt_local.indentkeys:remove("*<Return>")
