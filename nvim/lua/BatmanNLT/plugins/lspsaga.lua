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

		-- Work around two upstream lspsaga bugs (current HEAD) in the outline
		-- preview window:
		--   1. When a symbol's range extracts no buffer lines,
		--      get_max_content_length returns nil, then
		--      math.min(max_width, nil) errors in calc_preview_win_spec.
		--      Guard it to fall back to 0.
		--   2. With empty content, calc_preview_win_spec then yields a width
		--      of 0 (and a height of 0 when no lines at all), which
		--      nvim_win_set_config rejects with "Invalid 'width': expected
		--      positive Integer". Clamp both dimensions to at least 1 so the
		--      preview degrades to a minimal valid window instead of crashing.
		local util = require("lspsaga.util")
		local orig_get_max_content_length = util.get_max_content_length
		util.get_max_content_length = function(contents)
			return orig_get_max_content_length(contents) or 0
		end

		local outline = require("lspsaga.symbol.outline")
		local orig_calc_preview_win_spec = outline.calc_preview_win_spec
		outline.calc_preview_win_spec = function(self, lines)
			local spec = orig_calc_preview_win_spec(self, lines)
			spec.width = math.max(spec.width or 1, 1)
			spec.height = math.max(spec.height or 1, 1)
			return spec
		end
	end,
}
