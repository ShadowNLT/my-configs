return {
	"nvimdev/lspsaga.nvim",
	event = "LspAttach",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	config = function()
		require("lspsaga").setup({
			ui = {
				border = "rounded",
				winblend = 0,
			},
			-- Winbar breadcrumb: file path + code symbols.
			-- folder_level = how many parent dirs to show before the filename.
			symbol_in_winbar = {
				enable = true,
				folder_level = 4,
			},
			lightbulb = {
				enable = true,
				sign = true,
				virtual_text = true,
			},
		})

		-- Work around an upstream lspsaga bug (current HEAD): the outline
		-- preview window crashes with "bad argument #2 to 'min' (number
		-- expected, got nil)" when a symbol's range extracts no buffer lines.
		-- get_max_content_length returns nil for empty content, then
		-- math.min(max_width, nil) errors in calc_preview_win_spec. Guard it
		-- to fall back to 0 so the preview just renders a zero-width window.
		local util = require("lspsaga.util")
		local orig_get_max_content_length = util.get_max_content_length
		util.get_max_content_length = function(contents)
			return orig_get_max_content_length(contents) or 0
		end
	end,
}
