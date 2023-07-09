local log = require("qvim.log")

---@class nvim_tree : core_base
---@field enabled boolean|fun():boolean|nil
---@field options table|nil
---@field keymaps table|nil
---@field main string
---@field setup fun(self: table)|nil
---@field url string
local nvim_tree = {
  enabled = true,
  options = {},
  keymaps = {},
  main = nil,
  setup = nil,
  url = nil,
}

nvim_tree.__index = nvim_tree

return nvim_tree
