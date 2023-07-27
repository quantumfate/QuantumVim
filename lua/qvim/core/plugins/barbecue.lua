---@class barbecue : core_meta_plugin
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: barbecue, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: barbecue)|nil overwrite the setup function in core_base
---@field on_setup_done fun(self: barbecue, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local barbecue = {
  enabled = true,
  name = nil,
  options = {
    -- barbecue option configuration
    theme = "catppuccin-mocha",
    attach_navic = false,   -- done automatically on attach in lsp
    show_modified = true,
    create_autocmd = false, -- autocammand is defined
    kinds = {
      File = qvim.icons.kind.File,
      Module = qvim.icons.kind.Module,
      Namespace = qvim.icons.kind.Namespace,
      Package = qvim.icons.kind.Package,
      Class = qvim.icons.kind.Class,
      Method = qvim.icons.kind.Method,
      Property = qvim.icons.kind.Property,
      Field = qvim.icons.kind.Field,
      Constructor = qvim.icons.kind.Constructor,
      Enum = qvim.icons.kind.Enum,
      Interface = qvim.icons.kind.Interface,
      Function = qvim.icons.kind.Function,
      Variable = qvim.icons.kind.Variable,
      Constant = qvim.icons.kind.Constant,
      String = qvim.icons.kind.String,
      Number = qvim.icons.kind.Number,
      Boolean = qvim.icons.kind.Boolean,
      Array = qvim.icons.kind.Array,
      Object = qvim.icons.kind.Object,
      Key = qvim.icons.kind.Key,
      Null = qvim.icons.kind.Null,
      EnumMember = qvim.icons.kind.EnumMember,
      Struct = qvim.icons.kind.Struct,
      Event = qvim.icons.kind.Event,
      Operator = qvim.icons.kind.Operator,
      TypeParameter = qvim.icons.kind.TypeParameter,
    }
  },
  keymaps = {},
  main = "barbecue",
  on_setup_start = nil,
  setup = nil,
  on_setup_done = nil,
  url = "https://github.com/utilyre/barbecue.nvim",
}

barbecue.__index = barbecue

return barbecue
