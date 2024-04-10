" Treesitter has @function.builtin.nix link to Special.
" Idk why the semantic tokens and plugin don't do the same.
highlight link nixSimpleBuiltin Special
highlight link @lsp.mod.builtin.nix Special

" Nothing else in Nixlang would be considered a "type" so let's just make
" path literals use that highlight group, which otherwise get "Special".
highlight link nixPath Type
highlight link @string.special.path.nix Type
