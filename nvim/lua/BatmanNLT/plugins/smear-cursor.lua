-- smear-cursor.nvim — Neovide-style animated cursor in the terminal.
-- Official "faster smear" dynamics: snappier head, shorter trail, less bounce.
-- Toggle: :SmearCursorToggle
return {
	"sphamba/smear-cursor.nvim",
	opts = {
		-- Ghostty cursor-color; some terminals ignore Neovim's Cursor highlight.
		cursor_color = "#ffffff",

		smear_between_buffers = true,
		smear_between_neighbor_lines = true,
		smear_insert_mode = true,
		-- Ghostty `cursor-style = bar` — keep the insert smear as a vertical bar.
		vertical_bar_cursor_insert_mode = true,

		-- Official faster smear (closest to Neovide's default animated cursor)
		stiffness = 0.8, -- default 0.6
		trailing_stiffness = 0.6, -- default 0.45
		stiffness_insert_mode = 0.7, -- default 0.5
		trailing_stiffness_insert_mode = 0.7, -- default 0.5
		damping = 0.95, -- default 0.85; higher = less bounce
		damping_insert_mode = 0.95, -- default 0.9
		distance_stop_animating = 0.5, -- default 0.1; snaps sooner

		-- ~143fps draws (default 17ms ≈ 60fps). Drop back to 17 if CPU spikes.
		time_interval = 7,

		-- FiraCode Nerd Font does not ship legacy computing symbols.
		legacy_computing_symbols_support = false,
	},
}
