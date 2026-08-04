return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/lazydev.nvim", opts = {} },
		"mason-org/mason.nvim",
		"mason-org/mason-lspconfig.nvim",
	},
	config = function()
		-- import cmp-nvim-lsp plugin
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local keymap = vim.keymap -- for conciseness

		-- Make the LSP inlay-hint renderer crash-proof so hints never have to be
		-- disabled again. Neovim 0.12.3's decoration provider
		-- (runtime/lua/vim/lsp/inlay_hint.lua:362) renders each hint with
		-- nvim_buf_set_extmark(bufnr, ns, lnum, hint_col, ...). The store path
		-- clamps hint_col to the line length for the buffer version it was computed
		-- against (:81), but client_hints is keyed per client: when a second
		-- client's response advances bufstate.version, the first client's stale,
		-- already-clamped columns get re-rendered against a now-shorter line and
		-- nvim_buf_set_extmark throws "Invalid 'col': out of range". That error
		-- re-fires on every redraw (error -> notify -> redraw -> error), which is
		-- why hints used to be turned off entirely. We guard only the inlay-hint
		-- namespace: on that one error, re-clamp the column to the current line's
		-- byte length and retry, then drop the hint if it still fails — so a single
		-- bad hint can never spam or force the feature off. Every other extmark
		-- call is passed straight through (one integer comparison of overhead).
		if not vim.g._inlay_hint_extmark_guard then
			vim.g._inlay_hint_extmark_guard = true
			local inlay_ns = vim.api.nvim_create_namespace("nvim.lsp.inlayhint")
			local set_extmark = vim.api.nvim_buf_set_extmark
			vim.api.nvim_buf_set_extmark = function(bufnr, ns, lnum, col, opts)
				if ns ~= inlay_ns then
					return set_extmark(bufnr, ns, lnum, col, opts)
				end
				local ok, res = pcall(set_extmark, bufnr, ns, lnum, col, opts)
				if ok then
					return res
				end
				local line = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1]
				local clamped = math.min(col, line and #line or 0)
				local ok2, res2 = pcall(set_extmark, bufnr, ns, lnum, clamped, opts)
				return ok2 and res2 or nil
			end
		end

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				-- Buffer local mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local opts = { buffer = ev.buf, silent = true }
				local bufnr = ev.buf
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				-- Inlay hints are ENABLED. The "Invalid 'col': out of range" crash-loop
				-- that once forced these off (renderer at
				-- runtime/lua/vim/lsp/inlay_hint.lua:362 rendering a stale hint column
				-- past end-of-line) is now neutralized by the nvim_buf_set_extmark guard
				-- installed above, so a bad hint drops silently instead of spamming.
				local ENABLE_INLAY_HINTS = true
				if ENABLE_INLAY_HINTS and client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
					vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
				end
				-- set keybinds
				opts.desc = "Show LSP references"
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

				opts.desc = "Go to declaration"
				-- keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration
				keymap.set("n", "gD", "<cmd>Lspsaga goto_definition<CR>", opts)

				opts.desc = "Peek definition"
				keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", opts)
				-- opts.desc = "Show LSP definitions"
				-- keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

				opts.desc = "Code Action"
				keymap.set({ "n", "v" }, "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts)
				-- opts.desc = "See available code actions"
				-- keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", function()
					vim.diagnostic.jump({ count = -1 })
				end, opts) -- jump to previous diagnostic in buffer

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", function()
					vim.diagnostic.jump({ count = 1 })
				end, opts) -- jump to next diagnostic in buffer

				opts.desc = "Hover / Peek Documentation"
				keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts)
				-- opts.desc = "Show documentation for what is under cursor"
				-- keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

				opts.desc = "Toggle symbol outline"
				keymap.set("n", "<leader>co", "<cmd>Lspsaga outline<CR>", opts)

				opts.desc = "Finder — definitions + references"
				keymap.set("n", "<leader>cf", "<cmd>Lspsaga finder<CR>", opts)

				opts.desc = "Incoming calls (call hierarchy)"
				keymap.set("n", "<leader>ci", "<cmd>Lspsaga incoming_calls<CR>", opts)

				opts.desc = "Outgoing calls (call hierarchy)"
				keymap.set("n", "<leader>cO", "<cmd>Lspsaga outgoing_calls<CR>", opts)

				opts.desc = "Restart LSP"
				-- nvim-lspconfig removed the :Lsp* user commands, so :LspRestart now
				-- errors (E492). Restart via the native API: stop this buffer's clients
				-- and re-fire FileType so vim.lsp.enable reattaches them fresh.
				keymap.set("n", "<leader>rs", function()
					local bufnr = vim.api.nvim_get_current_buf()
					for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
						client:stop(true)
					end
					vim.defer_fn(function()
						if vim.api.nvim_buf_is_valid(bufnr) then
							vim.api.nvim_exec_autocmds("FileType", { buffer = bufnr, modeline = false })
						end
					end, 100)
				end, opts)

				-- Remove unused imports on save for TS/JS via tsserver code action
				if client and client.name == "vtsls" then
					local ts_fts = { typescript = true, typescriptreact = true, javascript = true, javascriptreact = true }
					if ts_fts[vim.bo[ev.buf].filetype] then
						vim.api.nvim_create_autocmd("BufWritePre", {
							buffer = ev.buf,
							callback = function()
								local params = vim.lsp.util.make_range_params(nil, client.offset_encoding)
								params.context = { diagnostics = {}, only = { "source.removeUnusedImports" } }
								local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
								for cid, res in pairs(result or {}) do
									local c = vim.lsp.get_client_by_id(cid)
									local enc = (c or {}).offset_encoding or "utf-16"
									for _, action in pairs(res.result or {}) do
										local edit = action.edit
										-- vtsls returns source.removeUnusedImports WITHOUT an inline
										-- edit (only a `data` handle), so it has to be fetched via
										-- codeAction/resolve first — otherwise there is nothing to
										-- apply and the unused imports silently survive.
										if not edit and action.data and c then
											local resolved = c:request_sync("codeAction/resolve", action, 3000, 0)
											edit = resolved and resolved.result and resolved.result.edit
										end
										if edit then
											vim.lsp.util.apply_workspace_edit(edit, enc)
										end
									end
								end
							end,
						})
					end
				end
			end,
		})

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Apply cmp's snippet-capable capabilities to EVERY server (current and any
		-- added later, including ones auto-enabled by mason-lspconfig), so function-
		-- argument placeholders work everywhere the server supports them. Servers that
		-- need an extra opt-in beyond snippet support set it in their own block below
		-- (gopls: usePlaceholders, lua_ls: callSnippet).
		vim.lsp.config("*", { capabilities = capabilities })

		vim.diagnostic.config({
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = "󰠠 ",
					[vim.diagnostic.severity.INFO] = " ",
				},
				-- optional: highlight line number / line for each severity
				numhl = {
					[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
					[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
					[vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
					[vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
				},
				-- linehl = { [vim.diagnostic.severity.ERROR] = "ErrorMsg" },
			},
			-- virtual_text = true,
			virtual_lines = true,
			underline = true,
		})

		-- ⬇️ Per-server config using the native API (Neovim 0.11+)
		vim.lsp.config.lua_ls = {
			capabilities = capabilities,
			settings = {
				Lua = {
					diagnostics = { globals = { "vim" } },
					completion = { callSnippet = "Replace" },
				},
			},
		}

		vim.lsp.config.vtsls = {
			capabilities = capabilities,
			filetypes = {
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
			},
			settings = {
				vtsls = {
					-- Favor the repo's own TypeScript (node_modules/typescript) when a
					-- project ships one, falling back to vtsls's bundled version only when
					-- it doesn't. Default is false, which pins every project to the bundled
					-- version and makes editor diagnostics disagree with the repo's tsc.
					autoUseWorkspaceTsdk = true,
				},
				typescript = {
					-- Auto-insert () + tab-navigable arg placeholders on function/method
					-- completion — VS Code's typescript.suggest.completeFunctionCalls, the
					-- Go `usePlaceholders` equivalent. vtsls emits the snippet on resolve
					-- and nvim-cmp applies it. (ts_ls never emitted this, which is why we
					-- switched servers.)
					suggest = { completeFunctionCalls = true },
					-- vtsls consumes VS Code-style settings (same reason
					-- suggest.completeFunctionCalls works above), so inlay hints must use
					-- the VS Code nested schema — parameterNames.enabled, parameterTypes,
					-- etc. The ts_ls-style "includeInlay*" preference keys are NOT in
					-- vtsls's configuration.schema.json and are silently dropped, which is
					-- why hints rendered in Go but never in TS/TSX. Note the inverted
					-- booleans: includeInlay…WhenArgumentMatchesName = false becomes
					-- suppressWhenArgumentMatchesName = true.
					inlayHints = {
						parameterNames = { enabled = "all", suppressWhenArgumentMatchesName = true },
						parameterTypes = { enabled = true },
						variableTypes = { enabled = true, suppressWhenTypeMatchesName = true },
						propertyDeclarationTypes = { enabled = true },
						functionLikeReturnTypes = { enabled = true },
						enumMemberValues = { enabled = true },
					},
				},
				javascript = {
					suggest = { completeFunctionCalls = true },
					-- vtsls consumes VS Code-style settings (same reason
					-- suggest.completeFunctionCalls works above), so inlay hints must use
					-- the VS Code nested schema — parameterNames.enabled, parameterTypes,
					-- etc. The ts_ls-style "includeInlay*" preference keys are NOT in
					-- vtsls's configuration.schema.json and are silently dropped, which is
					-- why hints rendered in Go but never in TS/TSX. Note the inverted
					-- booleans: includeInlay…WhenArgumentMatchesName = false becomes
					-- suppressWhenArgumentMatchesName = true.
					inlayHints = {
						parameterNames = { enabled = "all", suppressWhenArgumentMatchesName = true },
						parameterTypes = { enabled = true },
						variableTypes = { enabled = true, suppressWhenTypeMatchesName = true },
						propertyDeclarationTypes = { enabled = true },
						functionLikeReturnTypes = { enabled = true },
						enumMemberValues = { enabled = true },
					},
				},
			},
		}

		vim.lsp.config.graphql = {
			capabilities = capabilities,
			filetypes = { "graphql", "gql" },
		}

		vim.lsp.config.angularls = {
			capabilities = capabilities,
			filetypes = { "html", "typescript" },
		}

		vim.lsp.config.emmet_ls = {
			capabilities = capabilities,
			filetypes = { "html", "css", "sass", "scss", "less", "javascriptreact", "typescriptreact" },
		}

		vim.lsp.config.gopls = {
			capabilities = capabilities, -- e.g. from cmp_nvim_lsp.default_capabilities()
			settings = {
				gopls = {
					analyses = {
						unusedparams = true,
						unreachable = true,
						shadow = true,
					},
					staticcheck = true,
					usePlaceholders = true, -- fill function args as ${1:..} placeholders on completion (Go equivalent of lua_ls callSnippet)
					-- gofumpt = true, -- stricter formatting rules
					hints = {
						parameterNames = true, -- show parameter name hints in calls
						assignVariableTypes = true, -- show types in `x, y := ...`
						rangeVariableTypes = true, -- show types for `for k, v := range ...`
						compositeLiteralTypes = true, -- show types in composite literals
						compositeLiteralFieldNames = true, -- show field names in literals
						constantValues = true, -- show computed constant values
						functionTypeParameters = true, -- show generic parameter lists
					},
				},
			},
		}

		-- Attach to buffers that were already open before this plugin loaded — e.g.
		-- files restored by auto-session at startup. Those buffers already fired
		-- their FileType event, so they miss the autocmd vim.lsp.enable() uses to
		-- start a server (which is why the *first* file often opens "dead" until a
		-- restart). Re-fire FileType for each loaded buffer that has a filetype;
		-- vim.lsp.start reuses an existing client, so this never duplicates one.
		-- Deferred so server enabling and the configs above are fully registered.
		vim.schedule(function()
			for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].filetype ~= "" then
					vim.api.nvim_exec_autocmds("FileType", { buffer = bufnr, modeline = false })
				end
			end
		end)
	end,
}
