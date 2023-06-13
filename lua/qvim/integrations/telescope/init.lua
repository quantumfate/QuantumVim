---The telescope configuration file
local M = {}

local Log = require "qvim.integrations.log"

---@alias telescope_themes
---| "cursor"   # see `telescope.themes.get_cursor()`
---| "dropdown" # see `telescope.themes.get_dropdown()`
---| "ivy"      # see `telescope.themes.get_ivy()`
---| "center"   # retain the default telescope theme

---Registers the global configuration scope for telescope
function M:init()
  local actions = require("qvim.utils.modules").require_on_exported_call "telescope.actions"
  local builtin = require("qvim.utils.modules").require_on_exported_call "telescope.builtin"
  local telescope = {
    active = true,
    on_config_done = nil,
    keymaps = {
      {
        binding_group = "s",
        name = "Search",
        bindings = {
          ["cb"] = { rhs = "<cmd>Telescope git_branches<cr>", desc = "Checkout branch" },
          c = { rhs = "<cmd>Telescope colorscheme<cr>", desc = "Colorscheme" },
          h = { rhs = "<cmd>Telescope help_tags<cr>", desc = "Find Help" },
          M = { rhs = "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
          r = { rhs = "<cmd>Telescope oldfiles<cr>", desc = "Open Recent File" },
          R = { rhs = "<cmd>Telescope registers<cr>", desc = "Registers" },
          k = { rhs = "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
          C = { rhs = "<cmd>Telescope commands<cr>", desc = "Commands" },
          f = { rhs = "", desc = "Fuzzy find files", callback = builtin.find_files },
          l = { rhs = "", desc = "Live grep", callback = builtin.live_grep },
          b = { rhs = "", desc = "Show buffers", callback = builtin.buffers },
        },
        options = {
          prefix = "<leader>"
        }
      }
    },
    theme = "dropdown", ---@type telescope_themes
    options = {
      -- telescope option configuration
      prompt_prefix = qvim.icons.ui.Telescope .. " ",
      selection_caret = qvim.icons.ui.Forward .. " ",
      entry_prefix = "  ",
      initial_mode = "insert",
      selection_strategy = "reset",
      sorting_strategy = nil,
      layout_strategy = nil,
      layout_config = {},
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--hidden",
        "--glob=!.git/",
      },
      ---@usage Mappings are fully customizable. Many familiar mapping patterns are setup as defaults.
      mappings = {
        i = {
          ["<C-n>"] = actions.move_selection_next,
          ["<C-p>"] = actions.move_selection_previous,
          ["<C-c>"] = actions.close,
          ["<C-j>"] = actions.cycle_history_next,
          ["<C-k>"] = actions.cycle_history_prev,
          ["<C-q>"] = function(...)
            actions.smart_send_to_qflist(...)
            actions.open_qflist(...)
          end,
          ["<CR>"] = actions.select_default,
        },
        n = {
          ["<C-n>"] = actions.move_selection_next,
          ["<C-p>"] = actions.move_selection_previous,
          ["<C-q>"] = function(...)
            actions.smart_send_to_qflist(...)
            actions.open_qflist(...)
          end,
        },
      },
      file_ignore_patterns = {},
      path_display = { "smart" },
      winblend = 0,
      border = {},
      borderchars = nil,
      color_devicons = true,
      set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
    },
    pickers = {
      find_files = {
        hidden = true,
      },
      live_grep = {
        --@usage don't include the filename in the search results
        only_sort_text = true,
      },
      grep_string = {
        only_sort_text = true,
      },
      buffers = {
        initial_mode = "normal",
        mappings = {
          i = {
            ["<C-d>"] = actions.delete_buffer,
          },
          n = {
            ["dd"] = actions.delete_buffer,
          },
        },
      },
      planets = {
        show_pluto = true,
        show_moon = true,
      },
      git_files = {
        hidden = true,
        show_untracked = true,
      },
      colorscheme = {
        enable_preview = true,
      },
    },
  }


  return telescope
end

function M:config()
  require("qvim.integrations.telescope.extensions"):config()

  local _telescope_options = qvim.integrations.telescope.options
  local _telescope_extensions = qvim.integrations.telescope.extensions
  qvim.integrations.telescope.options = vim.tbl_deep_extend("force", _telescope_options, _telescope_extensions)
end

---The telescope setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
  local status_ok, telescope = pcall(reload, "telescope")
  if not status_ok then
    Log:warn(string.format("The plugin '%s' could not be loaded.", telescope))
    return
  end
  local previewers = require "telescope.previewers"
  local sorters = require "telescope.sorters"

  local _telescope = qvim.integrations.telescope
  local _telescope_extensions = _telescope.extensions


  qvim.integrations.telescope = vim.tbl_extend("keep", {
    file_previewer = previewers.vim_buffer_cat.new,
    grep_previewer = previewers.vim_buffer_vimgrep.new,
    qflist_previewer = previewers.vim_buffer_qflist.new,
    file_sorter = sorters.get_fuzzy_file,
    generic_sorter = sorters.get_generic_fuzzy_sorter,
  }, qvim.integrations.telescope)

  local theme = require("telescope.themes")["get_" .. (_telescope.theme or "")]
  if theme then
    _telescope.defaults = theme(_telescope.defaults)
  end

  telescope.setup(_telescope.options)
  if qvim.integrations.project.active then
    pcall(function()
      require("telescope").load_extension "projects"
    end)
  end

  for _, value in ipairs(_telescope_extensions.options.extensions_to_load) do
    -- important to call after telescope setup
    telescope.load_extension(value)
  end

  if _telescope.on_config_done then
    _telescope.on_config_done()
  end
end

return M
