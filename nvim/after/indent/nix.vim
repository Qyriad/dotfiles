set expandtab
set shiftwidth=2
lua << EOF
-- The vim-nix plugin automatically re-indents the current line on these keywords.
-- I disagree with its indentation, so I'm just going to remove them.
vim.opt.indentkeys:remove "0=in"
vim.opt.indentkeys:remove "0=inherit"
vim.opt.indentkeys:remove "0=then"
vim.opt.indentkeys:remove "0=else"
vim.opt.indentkeys:remove "*<Return>"
EOF
