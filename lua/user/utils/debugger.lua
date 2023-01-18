local utils = require("user.utils.util")
local debug = utils:require_module("debug")
local os = utils:require_module("os")

local M = {}

function M:print_table_pretty(table, indent)
  indent = indent or ""
  for key, value in pairs(table) do
    print(indent .. key .. ":")
    if type(value) == "table" then
      M:print_table_pretty(value, indent .. "    ")
    else
      print(indent .. "    " .. value)
    end
  end
end

return M
