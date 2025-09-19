return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				less = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				graphql = { "prettier" },
				liquid = { "prettier" },
				lua = { "stylua" },
				python = { "isort", "black" },
				go = { "goimports_reviser", "goimports", "gofumpt", "golines" },
			},
			formatters = {
				goimports_reviser = {
					command = "goimports-reviser",
					stdin = false,
					args = function(ctx)
						-- Resolve a stable dirname for go.mod lookup
						local bufnr = (type(ctx.buf) == "number" and ctx.buf) or vim.api.nvim_get_current_buf()
						local fname = ctx.filename
						if not fname or fname == "" then
							local ok_name, got = pcall(vim.api.nvim_buf_get_name, bufnr)
							if ok_name and got and got ~= "" then
								fname = got
							end
						end
						local dirname = (fname and fname ~= "" and vim.fs.dirname(fname))
							or ctx.dirname
							or (vim.uv or vim.loop).cwd()

						-- Find nearest go.mod upwards
						local gomod = vim.fs.find("go.mod", { upward = true, path = dirname })[1]
						local mod
						if gomod then
							local f = io.open(gomod, "r")
							if f then
								local s = f:read("*a")
								f:close()
								mod = s:match("^module%s+([%w%p%-_/%.]+)") or s:match("\nmodule%s+([%w%p%-_/%.]+)")
							end
						end

						local args = {
							"-rm-unused",
							"-set-alias",
							"-format",
							"-imports-order",
							"std,general,company,project,blanked,dotted",
						}
						if mod then
							table.insert(args, "-project-name")
							table.insert(args, mod)
						end
						table.insert(args, "$FILENAME")
						return args
					end,

					-- ✅ Guard against temp/empty/unnamed buffers and files without a package decl
					condition = function(ctx)
						local uv = vim.uv or vim.loop
						-- Resolve filename reliably
						local bufnr = (type(ctx.buf) == "number" and ctx.buf) or vim.api.nvim_get_current_buf()
						local fname = ctx.filename
						if not fname or fname == "" then
							local ok_name, got = pcall(vim.api.nvim_buf_get_name, bufnr)
							if ok_name and got and got ~= "" then
								fname = got
							end
						end
						if not fname or fname == "" then
							return false
						end

						-- File must exist and be non-empty
						local ok_stat, st = pcall(uv.fs_stat, fname)
						if not ok_stat or not st or st.type ~= "file" or (st.size or 0) == 0 then
							return false
						end

						-- Buffer must look like a Go file with a package decl within first ~50 lines
						local ok_count, line_count = pcall(vim.api.nvim_buf_line_count, bufnr)
						if not ok_count then
							return false
						end
						local to = math.min(50, line_count)
						local ok_lines, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, 0, to, false)
						if not ok_lines then
							return false
						end
						for _, l in ipairs(lines) do
							if l:match("^%s*package%s+[%w_]+") then
								return true
							end
						end
						return false
					end,
				},
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 5000,
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 5000,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
