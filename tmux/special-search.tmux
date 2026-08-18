# vim: filetype=tmux

# The `-x`/`-y` arguments are window-relative but the cursor formats are pane-relative.
set-option -g @menu_cursor_x "#{e|+|:#{pane_x},#{cursor_x}}"
set-option -g @menu_cursor_y "#{e|+|:#{pane_y},#{cursor_y}}"

# Experimental.
# Mnemonic: "Special Search"
bind-key S {
	display-menu -x "#{E:@menu_cursor_x}" -y "#{E:@menu_cursor_y}" "builder for.*failed" 1 {
		# For binding failed Nix builds.
		copy-mode
		send-keys -X search-backward "builder for.*failed"
	} "^nix-repl>" 2 {
		copy-mode
		send-keys -X search-backward "^nix-repl>"
	} "cancel" 0 {

	}
}

