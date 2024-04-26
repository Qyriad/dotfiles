if #vim.fn.globpath(vim.o.runtimepath, 'lua/treesitter-context') > 0 then
	require("treesitter-context").setup {
		enable = false,
	}
end
