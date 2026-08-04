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
				signature = { enabled = true }, -- live param hints while typing inside a call
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
				-- Mute the "No information available" hover toast. On TSX/JSX several
				-- servers answer K: ts_ls returns the real doc, but emmet_ls/tailwindcss
				-- return nothing for a plain variable, and the empty ones fire this
				-- message even though the popup already shows. Must precede the catch-all
				-- notify route below — noice applies the first matching route.
				{
					filter = { find = "No information available" },
					opts = { skip = true },
				},
				-- Mute the tsserver "configFileSpecs" crash toast. Enabling inlay hints
				-- makes vtsls fire textDocument/inlayHint; on repos pinned to a
				-- TypeScript whose project-reload path hits this upstream bug (e.g.
				-- vivenu-seatmap on TS 5.7.3) the request intermittently fails with
				-- "-32603 … Cannot read properties of undefined (reading
				-- 'configFileSpecs')". It's a server-side TS bug we can't fix from the
				-- editor, and hints still render whenever the project isn't mid-reload,
				-- so we drop only the noisy error toast (matched on the unique
				-- "configFileSpecs" substring, so other inlay errors still surface).
				-- Remove once the repo's TypeScript is upgraded past the bug. Must
				-- precede the catch-all notify route below.
				{
					filter = { find = "configFileSpecs" },
					opts = { skip = true },
				},
				{
					filter = { event = "notify" },
					view = "notify",
				},
				-- Mute null-ls/none-ls progress toasts (e.g. "code_action null-ls"),
				-- which fire on nearly every cursor move as code actions are queried.
				-- Real LSP server progress (gopls indexing, etc.) still shows.
				{
					filter = {
						event = "lsp",
						kind = "progress",
						cond = function(message)
							local client = vim.tbl_get(message.opts, "progress", "client")
							return client == "null-ls"
						end,
					},
					opts = { skip = true },
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
