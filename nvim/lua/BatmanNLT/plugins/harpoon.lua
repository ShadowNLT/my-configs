-- harpoon (harpoon2 branch) — pin a small working set of files and jump to them
-- instantly by slot, instead of fuzzy-searching every time.
--   <leader>a    add current file to the list
--   <leader>m    toggle the quick menu (view / reorder / remove)
--   <leader>1-4  jump straight to pinned file 1-4
return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    local keymap = vim.keymap

    keymap.set("n", "<leader>a", function()
      harpoon:list():add()
    end, { desc = "Harpoon add file" })

    keymap.set("n", "<leader>m", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = "Harpoon quick menu" })

    keymap.set("n", "<leader>1", function()
      harpoon:list():select(1)
    end, { desc = "Harpoon to file 1" })

    keymap.set("n", "<leader>2", function()
      harpoon:list():select(2)
    end, { desc = "Harpoon to file 2" })

    keymap.set("n", "<leader>3", function()
      harpoon:list():select(3)
    end, { desc = "Harpoon to file 3" })

    keymap.set("n", "<leader>4", function()
      harpoon:list():select(4)
    end, { desc = "Harpoon to file 4" })
  end,
}
