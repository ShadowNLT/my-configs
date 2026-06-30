return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-buffer", -- source for text in buffer
    "hrsh7th/cmp-path", -- source for file system paths
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp",
    },
    "saadparwaiz1/cmp_luasnip", -- for autocompletion
    "rafamadriz/friendly-snippets", -- useful snippets
    "onsails/lspkind.nvim", -- vs-code like pictograms
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")

    -- Keep snippet-session tracking accurate WHILE you edit a placeholder, so Tab
    -- keeps jumping to the next one. LuaSnip's default only re-syncs on InsertLeave,
    -- which desyncs the jump after you type into the first placeholder (e.g. gopls
    -- fmt.Errorf: edit `format`, then Tab to `a` stops working). history=true also
    -- lets <S-Tab> jump back.
    luasnip.config.setup({
      history = true,
      updateevents = "TextChanged,TextChangedI",
    })

    -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
    require("luasnip.loaders.from_vscode").lazy_load()

    cmp.setup({
      completion = {
        completeopt = "menu,menuone,preview,noselect",
      },
      -- Rounded borders on the popup menu + docs window (craftzdog look).
      -- Cap the docs window so long signatures wrap into a tidy box instead of
      -- sprawling across the screen (matters when nvim is split into panes).
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered({
          max_width = 80,
          max_height = 20,
        }),
      },
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
        ["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
        -- Scroll docs: cmp's completion doc window when the menu is open, otherwise
        -- the noice signature/hover popup (so long docs are scrollable even while
        -- tabbing through snippet placeholders). Falls back to default if neither.
        ["<C-f>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.mapping.scroll_docs(4)(fallback)
          elseif require("noice.lsp").scroll(4) then
            -- scrolled the noice popup
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<C-b>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.mapping.scroll_docs(-4)(fallback)
          elseif require("noice.lsp").scroll(-4) then
            -- scrolled the noice popup
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
        ["<C-e>"] = cmp.mapping.abort(), -- close completion window
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
        -- Tab / S-Tab: jump through snippet placeholders (${1:mode} -> ${2:lhs} -> ...),
        -- and also move the completion menu selection when it's open.
        ["<Tab>"] = cmp.mapping(function(fallback)
          if luasnip.locally_jumpable(1) then
            luasnip.jump(1)
          elseif cmp.visible() then
            cmp.select_next_item()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          elseif cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip", keyword_length = 2 }, -- snippets (min 2 chars to avoid flooding on single keystrokes)
        { name = "buffer" }, -- text within current buffer
        { name = "path" }, -- file system paths
      }),
      formatting = {
        format = lspkind.cmp_format({
          maxwidth = 50,
          ellipsis_char = "...",
        }),
      },
    })
  end,
}
