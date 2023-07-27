---@class indent-blankline : core_meta_plugin
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: indent-blankline, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: indent-blankline)|nil overwrite the setup function in core_base
---@field on_setup_done fun(self: indent-blankline, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local indent_blankline = {
  enabled = true,
  name = nil,
  options = {
    show_current_context = true,
    show_current_context_start = true,
    show_trailing_blankline_indent = false,
    show_first_indent_level = true,
    blankline_enabled = false,
    use_treesitter = true,
    blankline_char = "▏",
    space_char = "⋅",
    char_highlight_list = {
      "IndentBlanklineIndent1",
      "IndentBlanklineIndent2",
      "IndentBlanklineIndent3",
      "IndentBlanklineIndent4",
      "IndentBlanklineIndent5",
      "IndentBlanklineIndent6",
    },
    buftype_exclude = { "nofile", "prompt", "quickfix, :terminal" },
    context_patterns = {
      "class",
      "return",
      "function",
      "method",
      "^if",
      "^fi",
      "^while",
      "jsx_element",
      "^for",
      "^object",
      "^table",
      "block",
      "arguments",
      "if_statement",
      "else_clause",
      "jsx_element",
      "jsx_self_closing_element",
      "try_statement",
      "catch_clause",
      "import_statement",
      "operation_type",
    },
    filetype_exclude = {
      "help",
      "startify",
      "dashboard",
      "packer",
      "neogitstatus",
      "NvimTree",
      "Trouble",
      "toggleterm",
    },
  },
  keymaps = {},
  main = "indent_blankline",
  on_setup_start = nil,
  ---@param self indent-blankline
  setup = function(self)
    vim.wo.colorcolumn = "99999"
    vim.cmd([[highlight IndentBlanklineIndent1 guifg=#2e2e2e gui=nocombine]])
    vim.cmd([[highlight IndentBlanklineIndent2 guifg=#2e2e2e gui=nocombine]])
    vim.cmd([[highlight IndentBlanklineIndent3 guifg=#2e2e2e gui=nocombine]])
    vim.cmd([[highlight IndentBlanklineIndent4 guifg=#2e2e2e gui=nocombine]])
    vim.cmd([[highlight IndentBlanklineIndent5 guifg=#2e2e2e gui=nocombine]])
    vim.cmd([[highlight IndentBlanklineIndent6 guifg=#2e2e2e gui=nocombine]])
    vim.opt.list = true
    require("qvim.core.util").call_super_setup(self)
  end,
  on_setup_done = nil,
  url = "https://github.com/lukas-reineke/indent-blankline.nvim",
}

indent_blankline.__index = indent_blankline

return indent_blankline
