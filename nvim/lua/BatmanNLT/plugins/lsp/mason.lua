return {
	"mason-org/mason.nvim",
	dependencies = {
		"mason-org/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		-- import mason
		local mason = require("mason")

		-- import mason-lspconfig
		local mason_lspconfig = require("mason-lspconfig")

		local mason_tool_installer = require("mason-tool-installer")

		-- enable mason and configure icons
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
			-- list of servers for mason to install
			ensure_installed = {
				"ts_ls",
				"html",
				"cssls",
				"tailwindcss",
				"lua_ls",
				"angularls",
				"graphql",
				"emmet_ls",
				"prismals",
				"sqls",
				"dockerls",
				"docker_compose_language_service",
				"pyright",
				"gopls",
				"eslint",
			},
		})

		mason_tool_installer.setup({
			ensure_installed = {
				"prettier", -- prettier formatter
				"stylua", -- lua formatter
				"isort", -- python formatter
				-- black managed via pipx (PEP 668 blocks Mason's pypi installer on Homebrew Python)
				"goimports", -- golang formatter
				"goimports-reviser", -- golang formatter
				"gofumpt", -- golang formatter
				"golines", -- golang formatter
				"pylint",
				"cspell", -- spell checker for code comments & prose
			},
		})
	end,
}
