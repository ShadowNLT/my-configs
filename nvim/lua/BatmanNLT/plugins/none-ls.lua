return {
	"nvimtools/none-ls.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"davidmh/cspell.nvim", -- cspell sources (none-ls dropped its bundled ones)
	},
	config = function()
		local null_ls = require("null-ls")
		local cspell = require("cspell")

		-- Global dictionary. "Add to dictionary" writes here and cspell reads it
		-- for every project, so words you teach it carry across repos. A
		-- project-local cspell.json (if present) takes precedence.
		local global_json = vim.fn.expand("~/.config/cspell/cspell.json")

		local cspell_config = {
			find_json = function(cwd)
				local project_json = cwd .. "/cspell.json"
				if vim.fn.filereadable(project_json) == 1 then
					return project_json
				end
				return global_json
			end,
		}

		-- Only spell-check filetypes where prose/comments matter — keeps cspell
		-- out of noisy places like JSON keys and lockfiles.
		local spell_fts = {
			"lua",
			"python",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"go",
			"graphql",
			"gql",
			"html",
			"css",
			"scss",
			"sass",
			"markdown",
			"text",
			"gitcommit",
			"sh",
			"bash",
		}

		null_ls.setup({
			sources = {
				cspell.diagnostics.with({
					filetypes = spell_fts,
					config = cspell_config,
					-- Spelling is advisory: render it quieter than real errors/warnings.
					diagnostics_postprocess = function(diagnostic)
						diagnostic.severity = vim.diagnostic.severity.HINT
					end,
				}),
				cspell.code_actions.with({
					filetypes = spell_fts,
					config = cspell_config,
				}),
			},
		})

		-- Toggle cspell on/off for a buffer that's drowning in false positives.
		vim.keymap.set("n", "<leader>cs", function()
			null_ls.toggle("cspell")
		end, { desc = "Toggle cspell spell-check" })

		-- VS Code-style express "add word to dictionary": auto-applies the cspell
		-- code action for the word under the cursor (cursor must be on the squiggle).
		vim.keymap.set("n", "<leader>cw", function()
			vim.lsp.buf.code_action({
				apply = true,
				filter = function(action)
					local title = (action.title or ""):lower()
					return title:find("add", 1, true) ~= nil and title:find("cspell", 1, true) ~= nil
				end,
			})
		end, { desc = "Add word under cursor to cspell dictionary" })
	end,
}
