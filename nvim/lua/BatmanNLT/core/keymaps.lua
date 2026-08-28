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
		client:stop(true) -- force so the restart is clean (vim.lsp.stop_client deprecated in 0.12)
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

-- Restart all of Neovim in place (nvim 0.11+ `:restart`) — reloads the entire
-- config without leaving the terminal. Use after editing config files, since
-- <leader>rs only bounces the language server with the *already loaded* config.
--
-- Two guards: (1) :restart (no bang) refuses on unsaved changes — we check first
-- and bail with a hint instead of half-acting. (2) noice.nvim (2025-11) crashes
-- on Neovim 0.12's `restart` UI event: its get_handler assumes every event name
-- has an underscore, and `restart` has none, so it concatenates nil. Detaching
-- noice's UI handler before :restart sidesteps that and lets the reload complete.
keymap.set("n", "<leader>qr", function()
	-- Only block on *real* file buffers that would make `:restart` (= :qall) fail.
	-- The old check `getbufinfo({bufmodified=1})` matched *any* modified buffer,
	-- including scratch/nofile/terminal buffers that never block :qall, which
	-- caused the false "Unsaved changes" warning even with no edits.
	local modified = {}
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].modified then
			local bt = vim.bo[buf].buftype
			if bt == "" or bt == "acwrite" then
				-- `buflisted` filters out most plugin scratch buffers; also
				-- allow an unlisted buffer if it actually has a filename (e.g. hidden file buffer)
				if vim.bo[buf].buflisted or vim.api.nvim_buf_get_name(buf) ~= "" then
					table.insert(modified, buf)
				end
			end
		end
	end
	if #modified > 0 then
		local names = {}
		for _, b in ipairs(modified) do
			local name = vim.api.nvim_buf_get_name(b)
			if name == "" then
				name = "[No Name]:" .. b
			else
				name = vim.fn.fnamemodify(name, ":~:.")
			end
			table.insert(names, name)
		end
		vim.notify(
			"Unsaved changes in: " .. table.concat(names, ", ") .. " — :w or :wa before restarting",
			vim.log.levels.WARN
		)
		return
	end
	pcall(function()
		require("noice").disable()
	end)
	vim.cmd("restart")
end, { desc = "Restart Neovim (reload full config)" })

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
