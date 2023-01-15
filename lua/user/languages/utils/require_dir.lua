local M = {}

local function scandir(directory)
  local i, t, popen = 0, {}, io.popen
  local pfile = popen('ls -a "'..directory..'"')
  for filename in pfile:lines() do
    i = i + 1
    t[i] = filename
  end
  pfile:close()
  return t
end

--- Require all the lua files from a directory in the 
-- file where this function is called. The function 
-- will exclude the file where this function is called meaning
-- it wont require circular. Optionally you can set a flag
-- that will make this function append the file names without
-- the .lua extension to a metatable which is then returned.
-- This will for example allow you to get a list of files
-- that are in the directory where this function is called.
--
-- @field module_name: The lua path to the module in which this
--                     function is called
-- @field inject_module_table: Optionally set a metatable for the 
--                             module in which this functio is called in
--
-- @return true without optional parameter otherwise a list 
--         containing the file names of the module except for the
--         file in which this function was called
function M:require_directory_files(module_name, inject_module_table)

  inject_module_table = inject_module_table or false

  local info = debug.getinfo(2, 'S')
  local module_directory = string.match(info.source, '^@(.*)/')
  local module_filename = string.match(info.source, '/([^/]*)$')

  -- Require all other `.lua` files in the same directory
   local config_files = vim.tbl_filter(function (filename)
    local is_lua_module = string.match(filename, "[.]lua$")
    local is_this_file = filename == module_filename
    return is_lua_module and not is_this_file
  end, scandir(module_directory))

  if inject_module_table then
    local obj = {}
    for i, filename in ipairs(config_files) do
      local config_module = string.match(filename, "(.+).lua$")
      obj[config_module] = require(module_name.."."..config_module)
    end
    setmetatable(obj, { __index = self })
    return obj
  else
    for i, filename in ipairs(config_files) do
      local config_module = string.match(filename, "(.+).lua$")
      require(module_name.."."..config_module)
    end
    return true
  end

end

return M
