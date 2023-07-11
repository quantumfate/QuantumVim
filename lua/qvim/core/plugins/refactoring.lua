---@class refactoring : core_meta_plugin
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps table|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: refactoring, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: refactoring)|nil overwrite the setup function in core_base
---@field on_setup_done fun(self: refactoring, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local refactoring = {
  enabled = true,
  name = nil,
  options = {
    -- refactoring option configuration
    -- prompt for return type
    prompt_func_return_type = {
      go = true,
      cpp = true,
      c = true,
      java = true,
    },
    -- prompt for function parameters
    prompt_func_param_type = {
      go = true,
      cpp = true,
      c = true,
      java = true,
    },
  },
  keymaps = {
    --[[  {
      binding_group = "r",
      name = "+Refactoring",
      bindings = {
        e = {
          mode = { "n", "v" },
          rhs = "<ESC><cmd>lua require('refactoring').refactor('Extract Function')<CR>",
          desc = "Extract Function",
        },
        f = {
          mode = "v",
          rhs = "<ESC><cmd>lua require('refactoring').refactor('Extract Function To File')<CR>",
          desc = "Extract Function To File",
        },
        v = {
          mode = "v",
          rhs = "<ESC><cmd>lua require('refactoring').refactor('Extract Variable')<CR>",
          desc = "Extract Variable",
        },
        i = {
          mode = "v",
          rhs = "<ESC><cmd>lua require('refactoring').refactor('Inline Variable')<CR>",
          desc = "Inline Variable",
        },
        b = {
          rhs = "<cmd>lua require('refactoring').refactor('Extract Block')<CR>",
          desc = "Extract Block",
        },
        ["bf"] = {
          rhs = "<cmd>lua require('refactoring').refactor('Extract Block To File')<CR>",
          desc = "Extract Block To File",
        },
      },
      options = {
        prefix = "<leader>",
        noremap = true,
        silent = true,
        expr = false,
      },
    }, ]]
  },
  main = "refactoring",
  on_setup_start = nil,
  setup = nil,
  on_setup_done = nil,
  url = "https://github.com/ThePrimeagen/refactoring.nvim",
}

refactoring.__index = refactoring

return refactoring
