vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

-- keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Revive a buffer that opened "dead" (no auto-pairs / no LSP completion) without
-- quitting nvim: re-run filetype detection and re-fire the FileType event so
-- treesitter, ftplugins and the LSP re-attach, then restart any language servers.
-- Global (unlike <leader>rs, which only exists after an LSP has attached).
keymap.set("n", "<leader>rr", function()
	vim.cmd("filetype detect")
	if vim.bo.filetype ~= "" then
		vim.api.nvim_exec_autocmds("FileType", { buffer = 0, modeline = false })
	end
	pcall(vim.cmd, "LspRestart")
end, { desc = "Revive buffer: re-detect filetype + restart LSP" })

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
