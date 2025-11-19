return {
	"folke/noice.nvim",
	event = "UIEnter",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},

	config = function()
		---------------------------------------------------------------------------
		-- KEYBINDING: dismiss notifications (Noice-managed)
		---------------------------------------------------------------------------
		vim.keymap.set("n", "<leader>nc", function()
			vim.cmd("Noice dismiss")
		end, { desc = "Dismiss all Noice messages" })

		---------------------------------------------------------------------------
		-- NOICE SETUP (stable + LSPSaga friendly)
		---------------------------------------------------------------------------
		require("noice").setup({
			-- Use nvim-notify as backend
			notify = {
				enabled = true,
			},

			-- Disable Noice LSP UI (you use LSPSaga)
			lsp = {
				progress = { enabled = true },
				hover = { enabled = false },
				signature = { enabled = false },
				message = { enabled = false },
				documentation = { enabled = false },
				override = {},
			},

			-- Enable popup command line (for rename.nvim, refactor.nvim, etc.)
			cmdline = {
				enabled = true,
				view = "cmdline_popup",
				format = {
					cmdline = { pattern = "^:", icon = "", lang = "vim" },
					search_down = { pattern = "^/", icon = " ", lang = "regex" },
					search_up = { pattern = "^%?", icon = " ", lang = "regex" },
				},
			},

			-- Notification view (top-right)
			views = {
				notify = {
					backend = "notify",
					replace = true,
					merge = true,
					position = {
						row = 1,
						col = -2,
					},
				},
			},

			-- Route all notifications to our notify view
			routes = {
				{
					filter = { event = "notify" },
					view = "notify",
				},
			},

			-- Safe presets (don’t conflict with LSPSaga)
			presets = {
				bottom_search = false,
				command_palette = false,
				long_message_to_split = true,
				inc_rename = false,
				lsp_doc_border = false,
			},
		})
	end,
}
