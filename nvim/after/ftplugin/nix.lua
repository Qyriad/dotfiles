if #vim.fn.globpath(vim.o.runtimepath, 'lua/treesitter-context') > 0 then
	require("treesitter-context").setup {
		enable = false,
	}
end

-- Hyphen-minus is an identifier character in Nix!
vim.opt_local.iskeyword:append("-")
