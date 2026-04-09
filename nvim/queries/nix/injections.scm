;; extends
; vim: noet ts=2 sw=0

(binding
	attrpath: ((attrpath) @_path
		(#match? @_path "^([a-z][A-Za-z]*Phase|(pre|post)[A-Z][A-Za-z]*|(.*\\.)?script)|(script)|(buildCommand)$"))
	expression: (
		(indented_string_expression
			((string_fragment) @injection.content)
			(#set! injection.language "bash")
			(#set! injection.combined)
		)
	)
)

; FIXME: apply to anything that is lib.dedent'd
(apply_expression
	function: (apply_expression
		;function: (_) @_func
		;	(#match? @_func "(^(dedent)$")
		function: (apply_expression
			function: (select_expression
				attrpath: (attrpath
					attr: (identifier)
				)
			)
		)
	)
	argument: (indented_string_expression
		((string_fragment) @injection.content)
		(#set! injection.language "bash")
	)
)



;(apply_expression
;  function: (apply_expression
;    function: ((_) @_func
;      (#match? @_func "(^|\\.)writeShellScript(Bin)?$")))
;  argument: (indented_string_expression) @bash)
;(apply_expression
;  (apply_expression
;    function: (apply_expression
;      function: ((_) @_func
;        (#match? @_func "(^|\\.)runCommand(CC|NoCC|Local|NoCCLocal)?$"))))
;  argument: (indented_string_expression) @bash)

;(binding
;	attrpath: (
;		(attrpath (identifier) @_path)
;		(#match? @_path "^(ExecStart)$")
;	)
;	expression: (string_expression
;		((string_fragment) @injection.content)
;		(#set! injection.language "systemd")
;	)
;)

;(indented_string_expression
;	((string_fragment) @injection.content)
;		(#set! injection.language "bash")
;		(#set! injection.combined)
;)

(binding
	attrpath: (attrpath
		(identifier) @_identifierPath
	)
	;expression: ((indented_string_expression) @injection.content
	;	(#set! injection.langauge "bash")
	;	(#set! injection.combined)
	;)
	expression: (indented_string_expression
		((string_fragment) @injection.content
			(#set! injection.language "bash")
			;(#set! injection.include-children)
			(#set! injection.combined)
		)
	)
)

; Common field names containg bash script.

;(binding
;  attrpath: ((attrpath) @_path
;    (#match? @_path "^([a-z][A-Za-z]*Phase|(pre|post)[A-Z][A-Za-z]*|(.*\\.)?script)$"))
;  expression: [
;    (indented_string_expression) @bash
;    (if_expression (indented_string_expression) @bash)
;    (let_expression body: (indented_string_expression) @bash)
;
;    ; Rough match over `lib.optionalString ''bar''`
;    (apply_expression function: (apply_expression) argument: (indented_string_expression) @bash)
;
;    ; Rough match inner expressions concated with `+`
;    (binary_expression [
;      (indented_string_expression) @bash
;      (parenthesized_expression [ (if_expression (indented_string_expression) @bash) (let_expression body: (indented_string_expression) @bash)])
;      (apply_expression function: (apply_expression) argument: (indented_string_expression) @bash)
;      (binary_expression [
;        (indented_string_expression) @bash
;        (parenthesized_expression [ (if_expression (indented_string_expression) @bash) (let_expression body: (indented_string_expression) @bash)])
;        (apply_expression function: (apply_expression) argument: (indented_string_expression) @bash)
;        (binary_expression [
;          (indented_string_expression) @bash
;          (parenthesized_expression [ (if_expression (indented_string_expression) @bash) (let_expression body: (indented_string_expression) @bash)])
;          (apply_expression function: (apply_expression) argument: (indented_string_expression) @bash)
;          (binary_expression [
;            (indented_string_expression) @bash
;            (parenthesized_expression [ (if_expression (indented_string_expression) @bash) (let_expression body: (indented_string_expression) @bash)])
;            (apply_expression function: (apply_expression) argument: (indented_string_expression) @bash)])])])])])
;
;; Trivial builders
;
;; FIXME: Write them together with `[]` will cause lua error.
;(apply_expression
;  function: (apply_expression
;    function: ((_) @_func
;      (#match? @_func "(^|\\.)writeShellScript(Bin)?$")))
;  argument: (indented_string_expression) @bash)
;(apply_expression
;  (apply_expression
;    function: (apply_expression
;      function: ((_) @_func
;        (#match? @_func "(^|\\.)runCommand(CC|NoCC|Local|NoCCLocal)?$"))))
;  argument: (indented_string_expression) @bash)
;
;; Manually marked with an indicator comment
;; FIXME: Cannot dynamic inject before `#offset!` issue being resolved.
;; See: https://github.com/neovim/neovim/issues/16032
;
;; Using `#set!` inside `[]` doesn't work, so we need to split these queries.
;(
;  ((comment) @_language (#any-of? @_language "# bash" "/* bash */") (#set! "language" "bash")) .
;  [
;    ((indented_string_expression) @content)
;    (binding
;      expression: [
;        (indented_string_expression) @content
;        (binary_expression (indented_string_expression) @content)
;        (apply_expression argument: (indented_string_expression) @content)])]
;  (#offset! @content 0 2 0 -2))
;(
;  ((comment) @_language (#any-of? @_language "# fish" "/* fish */") (#set! "language" "fish")) .
;  [
;    ((indented_string_expression) @content)
;    (binding
;      expression: [
;        (indented_string_expression) @content
;        (binary_expression (indented_string_expression) @content)
;        (apply_expression argument: (indented_string_expression) @content)])]
;  (#offset! @content 0 2 0 -2))
;(
;  ((comment) @_language (#any-of? @_language "# vim" "/* vim */") (#set! "language" "vim")) .
;  [
;    ((indented_string_expression) @content)
;    (binding
;      expression: [
;        (indented_string_expression) @content
;        (binary_expression (indented_string_expression) @content)
;        (apply_expression argument: (indented_string_expression) @content)])]
;  (#offset! @content 0 2 0 -2))
;(
;  ((comment) @_language (#any-of? @_language "# tmux" "/* tmux */") (#set! "language" "tmux")) .
;  [
;    ((indented_string_expression) @content)
;    (binding
;      expression: [
;        (indented_string_expression) @content
;        (binary_expression (indented_string_expression) @content)
;        (apply_expression argument: (indented_string_expression) @content)])]
;  (#offset! @content 0 2 0 -2))
;(
;  ((comment) @_language (#any-of? @_language "# toml" "/* toml */") (#set! "language" "toml")) .
;  [
;    ((indented_string_expression) @content)
;    (binding
;      expression: [
;        (indented_string_expression) @content
;        (binary_expression (indented_string_expression) @content)
;        (apply_expression argument: (indented_string_expression) @content)])]
;  (#offset! @content 0 2 0 -2))
;(
;  ((comment) @_language (#any-of? @_language "# yaml" "/* yaml */") (#set! "language" "yaml")) .
;  [
;    ((indented_string_expression) @content)
;    (binding
;      expression: [
;        (indented_string_expression) @content
;        (binary_expression (indented_string_expression) @content)
;        (apply_expression argument: (indented_string_expression) @content)])]
;  (#offset! @content 0 2 0 -2))
;(
;  ((comment) @_language (#any-of? @_language "# lua" "/* lua */") (#set! "language" "lua")) .
;  [
;    ((indented_string_expression) @content)
;    (binding
;      expression: [
;        (indented_string_expression) @content
;        (binary_expression (indented_string_expression) @content)
;        (apply_expression argument: (indented_string_expression) @content)])]
;  (#offset! @content 0 2 0 -2))
;
;; Reverse inject interpolation to override other injected languages.
;; I cannot find other way to correctly highlight interpolations inside injected string.
;; Related: https://github.com/nvim-treesitter/nvim-treesitter/issues/1688
;(interpolation
;  expression: (_) @nix)
;
;(comment) @comment
