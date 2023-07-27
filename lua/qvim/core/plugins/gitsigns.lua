---@class gitsigns : core_meta_plugin
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: gitsigns, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: gitsigns)|nil overwrite the setup function in core_base
---@field on_setup_done fun(self: gitsigns, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local gitsigns = {
  enabled = true,
  name = nil,
  options = {
    on_attach = function(bufnr)
      local wk = require("which-key")
      wk.register({
        g = {
          name = "git",
          ["g"] = { "<cmd>lua _LAZYGIT_TOGGLE()<CR>", "Lazygit" },
          ["j"] = { "<cmd>lua require 'gitsigns'.next_hunk()<cr>", "Next Hunk" },
          ["k"] = {
            "<cmd>lua require 'gitsigns'.prev_hunk()<cr>",
            "Prev Hunk",
            buffer = 0,
          },
          ["l"] = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" },
          ["p"] = {
            "<cmd>lua require 'gitsigns'.preview_hunk()<cr>",
            "Preview Hunk",
          },
          ["r"] = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
          ["R"] = {
            "<cmd>lua require 'gitsigns'.reset_buffer()<cr>",
            "Reset Buffer",
          },
          ["s"] = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" },
          ["u"] = {
            "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>",
            "Undo Stage Hunk",
          },
          ["o"] = { "<cmd>Telescope git_status<cr>", "Open changed file" },
          ["b"] = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
          ["c"] = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
          ["d"] = {
            "<cmd>Gitsigns diffthis HEAD<cr>",
            "Diff",
          },
        }
      }, {
        prefix = "<leader>",
        buffer = bufnr
      })
    end,
    -- gitsigns option configuration
    signs = {
      add = { hl = "GitSignsAdd", text = "▎", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
      change = {
        hl = "GitSignsChange",
        text = "▎",
        numhl = "GitSignsChangeNr",
        linehl = "GitSignsChangeLn",
      },
      delete = {
        hl = "GitSignsDelete",
        text = "契",
        numhl = "GitSignsDeleteNr",
        linehl = "GitSignsDeleteLn",
      },
      topdelete = {
        hl = "GitSignsDelete",
        text = "契",
        numhl = "GitSignsDeleteNr",
        linehl = "GitSignsDeleteLn",
      },
      changedelete = {
        hl = "GitSignsChange",
        text = "▎",
        numhl = "GitSignsChangeNr",
        linehl = "GitSignsChangeLn",
      },
    },
    signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
    numhl = false,     -- Toggle with `:Gitsigns toggle_numhl`
    linehl = false,    -- Toggle with `:Gitsigns toggle_linehl`
    word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
    watch_gitdir = {
      interval = 1000,
      follow_files = true,
    },
    attach_to_untracked = true,
    current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
      delay = 1000,
      ignore_whitespace = false,
    },
    current_line_blame_formatter_opts = {
      relative_time = false,
    },
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil, -- Use default
    max_file_length = 40000,
    preview_config = {
      -- Options passed to nvim_open_win
      border = "single",
      style = "minimal",
      relative = "cursor",
      row = 0,
      col = 1,
    },
    yadm = {
      enable = false,
    },
  },
  keymaps = {},
  main = "gitsigns",
  on_setup_start = nil,
  setup = nil,
  on_setup_done = nil,
  url = "https://github.com/lewis6991/gitsigns.nvim",
}

gitsigns.__index = gitsigns

return gitsigns
