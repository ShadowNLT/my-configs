vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

-- keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Revive a buffer that opened "dead" (no auto-pairs / no LSP completion) without
-- quitting nvim. Stop every client on the buffer — including none-ls's "null-ls",
-- which :LspRestart rejects as an invalid server name — then re-run filetype
-- detection and re-fire FileType so treesitter, ftplugins, the LSP servers and
-- none-ls all re-attach fresh. Global (unlike <leader>rs, which only exists after
-- an LSP has already attached).
keymap.set("n", "<leader>rr", function()
	local bufnr = vim.api.nvim_get_current_buf()
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
		vim.lsp.stop_client(client.id, true) -- force so the restart is clean
	end
	-- Deferred so the stopped clients have exited before the new ones start.
	vim.defer_fn(function()
		if not vim.api.nvim_buf_is_valid(bufnr) then
			return
		end
		vim.api.nvim_buf_call(bufnr, function()
			vim.cmd("filetype detect")
		end)
		if vim.bo[bufnr].filetype ~= "" then
			vim.api.nvim_exec_autocmds("FileType", { buffer = bufnr, modeline = false })
		end
	end, 100)
end, { desc = "Revive buffer: restart LSP + re-detect filetype" })

-- Increment/Decrement Numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- Window Management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- Tabs Management
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew<CR>", { desc = "Open current buffer in new tab" })
