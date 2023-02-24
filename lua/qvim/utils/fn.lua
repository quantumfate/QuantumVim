local M = {}

local Log = require "qvim.integrations.log"

---Replaces hyphons with underscores in a string
---@param val string
function M.normalize(val)
  if val and type(val) == "string" then
    if not string.find(val, "-") then
      return val
    end
    return val:gsub("-", "_")
  end
  return val
end

---Calls rawget and prints debug information
---@param t any
---@param k any
---@param s string? the name of the table
---@return any
function M.rawget_debug(t, k, s)
  s = s or tostring(t)
  Log:debug(string.format("The integration '%s' was referenced from the '%s' table.", k, s))
  return rawget(t, k)
end

---Calls rawset and prints debug integration
---@param t any
---@param k any
---@param v any
---@param s string? the name of the table
---@return table
function M.rawset_debug(t, k, v, s)
  s = s or tostring(t)
  Log:debug(string.format("Added integration '%s' to the '%s' table.", k, s))
  return rawset(t, k, v)
end

function M.isempty(s)
  return s == nil or s == ""
end

function M.get_buf_option(opt)
  local status_ok, buf_option = pcall(vim.api.nvim_buf_get_option, 0, opt)
  if not status_ok then
    return nil
  else
    return buf_option
  end
end

return M
