local cmp_types = require("qvim.utils.modules").require_on_index("cmp.types.cmp")
local methods = require("qvim.core.plugins.nvim-cmp.methods")
local _cmp = require("qvim.utils.modules").require_on_index("cmp")
local luasnip = require("qvim.utils.modules").require_on_index("luasnip")
local cmp_window = require("qvim.utils.modules").require_on_index("cmp.config.window")
local cmp_mapping = require("cmp.config.mapping")


---@class nvim-cmp : core_meta_parent
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: nvim-cmp, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: nvim-cmp)|nil overwrite the setup function in core_base
---@field on_setup_done fun(self: nvim-cmp, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
---@field has_words_before fun():boolean
---@field feedkeys fun(key: string, mode:string)
---@field jumpable fun(dir: number):boolean
local nvim_cmp = {
  enabled = true,
  name = nil,
  options = {
    -- cmp option configuration
    enabled = function()
      local buftype = vim.api.nvim_buf_get_option(0, "buftype")
      if buftype == "prompt" then
        return false
      end
      if require("cmp_dap").is_dap_buffer() then
        return true
      end
      return qvim.plugins.nvim_cmp.enabled
    end,
    confirm_opts = {
      behavior = cmp_types.ConfirmBehavior.Replace,
      select = false,
    },
    completion = {
      ---@usage The minimum length of a word to complete on.
      keyword_length = 1,
    },
    experimental = {
      ghost_text = false,
      native_menu = false,
    },
    filetype = {
      "dap-repl",
      "dapui_watches",
      "dapui_hover",
    },
    formatting = {
      fields = { "kind", "abbr", "menu" },
      max_width = 0,
      kind_icons = qvim.icons.kind,
      source_names = {
        nvim_lsp = "(LSP)",
        emoji = "(Emoji)",
        path = "(Path)",
        calc = "(Calc)",
        cmp_tabnine = "(Tabnine)",
        vsnip = "(Snippet)",
        luasnip = "(Snippet)",
        buffer = "(Buffer)",
        tmux = "(TMUX)",
        copilot = "(Copilot)",
        treesitter = "(TreeSitter)",
      },
      duplicates = {
        buffer = 1,
        path = 1,
        nvim_lsp = 0,
        luasnip = 1,
      },
      duplicates_default = 0,
      format = function(entry, vim_item)
        local max_width = qvim.plugins.nvim_cmp.options.formatting.max_width
        if max_width ~= 0 and #vim_item.abbr > max_width then
          vim_item.abbr = string.sub(vim_item.abbr, 1, max_width - 1) .. qvim.icons.ui.Ellipsis
        end
        if qvim.config.use_icons then
          vim_item.kind = qvim.plugins.nvim_cmp.options.formatting.kind_icons[vim_item.kind]

          if entry.source.name == "copilot" then
            vim_item.kind = qvim.icons.git.Octoface
            vim_item.kind_hl_group = "CmpItemKindCopilot"
          end

          if entry.source.name == "cmp_tabnine" then
            vim_item.kind = qvim.icons.misc.Robot
            vim_item.kind_hl_group = "CmpItemKindTabnine"
          end

          if entry.source.name == "crates" then
            vim_item.kind = qvim.icons.misc.Package
            vim_item.kind_hl_group = "CmpItemKindCrate"
          end

          if entry.source.name == "lab.quick_data" then
            vim_item.kind = qvim.icons.misc.CircuitBoard
            vim_item.kind_hl_group = "CmpItemKindConstant"
          end

          if entry.source.name == "emoji" then
            vim_item.kind = qvim.icons.misc.Smiley
            vim_item.kind_hl_group = "CmpItemKindEmoji"
          end
        end
        vim_item.menu = qvim.plugins.nvim_cmp.options.formatting.source_names[entry.source.name]
        vim_item.dup = qvim.plugins.nvim_cmp.options.formatting.duplicates[entry.source.name]
            or qvim.plugins.nvim_cmp.options.formatting.duplicates_default
        return vim_item
      end,
    },
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    window = {
      completion = cmp_window.bordered(),
      documentation = cmp_window.bordered(),
    },
    sources = {
      {
        name = "copilot",
        -- keyword_length = 0,
        max_item_count = 3,
        trigger_characters = {
          {
            ".",
            ":",
            "(",
            "'",
            '"',
            "[",
            ",",
            "#",
            "*",
            "@",
            "|",
            "=",
            "-",
            "{",
            "/",
            "\\",
            "+",
            "?",
            " ",
            -- "\t",
            -- "\n",
          },
        },
      },
      {
        name = "nvim_lsp",
        entry_filter = function(entry, ctx)
          local kind = require("cmp.types.lsp").CompletionItemKind[entry:get_kind()]
          if kind == "Snippet" and ctx.prev_context.filetype == "java" then
            return false
          end
          return true
        end,
      },

      { name = "path" },
      { name = "luasnip" },
      { name = "cmp_tabnine" },
      { name = "nvim_lua" },
      { name = "buffer" },
      { name = "calc" },
      { name = "emoji" },
      { name = "treesitter" },
      { name = "crates" },
      { name = "tmux" },
      { name = "dap" },
    },
    mapping = cmp_mapping.preset.insert({
      ["<C-k>"] = cmp_mapping(cmp_mapping.select_prev_item(), { "i", "c" }),
      ["<C-j>"] = cmp_mapping(cmp_mapping.select_next_item(), { "i", "c" }),
      ["<Down>"] = cmp_mapping(cmp_mapping.select_next_item({ behavior = cmp_types.SelectBehavior.Select }), { "i" }),
      ["<Up>"] = cmp_mapping(cmp_mapping.select_prev_item({ behavior = cmp_types.SelectBehavior.Select }), { "i" }),
      ["<C-d>"] = cmp_mapping.scroll_docs(-4),
      ["<C-f>"] = cmp_mapping.scroll_docs(4),
      ["<C-y>"] = cmp_mapping({
        i = cmp_mapping.confirm({ behavior = cmp_types.ConfirmBehavior.Replace, select = false }),
        c = function(fallback)
          if _cmp.visible() then
            _cmp.confirm({ behavior = cmp_types.ConfirmBehavior.Replace, select = false })
          else
            fallback()
          end
        end,
      }),
      ["<Tab>"] = cmp_mapping(function(fallback)
        if _cmp.visible() then
          _cmp.select_next_item()
        elseif luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
        elseif methods.jumpable(1) then
          luasnip.jump(1)
        elseif methods.has_words_before() then
          -- cmp.complete()
          fallback()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp_mapping(function(fallback)
        if _cmp.visible() then
          _cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<C-Space>"] = cmp_mapping.complete(),
      ["<C-e>"] = cmp_mapping.abort(),
      ["<CR>"] = cmp_mapping(function(fallback)
        if _cmp.visible() then
          local confirm_opts = vim.deepcopy(qvim.plugins.nvim_cmp.options.confirm_opts) -- avoid mutating the original opts below
          local is_insert_mode = function()
            return vim.api.nvim_get_mode().mode:sub(1, 1) == "i"
          end
          if is_insert_mode() then -- prevent overwriting brackets
            confirm_opts.behavior = cmp_types.ConfirmBehavior.Insert
          end
          local entry = _cmp.get_selected_entry()
          local is_copilot = entry and entry.source.name == "copilot"
          if is_copilot then
            confirm_opts.behavior = cmp_types.ConfirmBehavior.Replace
            confirm_opts.select = true
          end
          if _cmp.confirm(confirm_opts) then
            return -- success, exit early
          end
        end
        fallback() -- if not exited early, always fallback
      end),
    }),
    cmdline = {
      enable = false,
      options = {
        {
          type = ":",
          sources = {
            { name = "path" },
            { name = "cmdline" },
          },
        },
        {
          type = { "/", "?" },
          sources = {
            { name = "buffer" },
          },
        },
      },
    },
  },
  keymaps = {
    -- TODO: do cmp mappings
  },
  main = "cmp",
  on_setup_start = nil,
  setup = nil,
  ---@param self nvim-cmp
  ---@param cmp table
  on_setup_done = function(self, cmp)
    for _, opt in ipairs(self.options.cmdline.options) do
      cmp.setup.cmdline(opt.type, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = opt.sources,
      })
    end
    cmp.setup.filetype(self.options.filetype, {
      sources = {
        name = "dap"
      }
    })
  end,

  url = "https://github.com/hrsh7th/nvim-cmp",
}

nvim_cmp.has_words_before = methods.has_words_before
nvim_cmp.feedkeys = methods.feedkeys
nvim_cmp.jumpable = methods.jumpable

nvim_cmp.__index = nvim_cmp

return nvim_cmp
