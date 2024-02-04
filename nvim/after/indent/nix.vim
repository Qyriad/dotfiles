setlocal expandtab
setlocal shiftwidth=2
lua << EOF
-- The vim-nix plugin automatically re-indents the current line on these keywords.
-- I disagree with its indentation, so I'm just going to remove them.
vim.opt_local.indentkeys:remove "0=in"
vim.opt_local.indentkeys:remove "0=inherit"
vim.opt_local.indentkeys:remove "0=then"
vim.opt_local.indentkeys:remove "0=else"
vim.opt_local.indentkeys:remove "*<Return>"
EOF
