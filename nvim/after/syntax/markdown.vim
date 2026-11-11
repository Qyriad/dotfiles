" Make escape characters in markdown `conceal`able, mostly for LSP-hover-reasons.
syntax match markdownEscape "\\[][\\`*_{}()<>#+.!-]" conceal
