local M = {}
local debug = require("debug")
local os = require("os")

function M:set_use_xpcall(use_xpcall)
	use_xpcall = use_xpcall or false
	return use_xpcall
end

function M:show_variables_in_trace(set_variables)
  set_variables = set_variables or false
  return set_variables
end

--- Wrapper function to easily switch between pcall and xpcall.
-- 
-- Default values:
--  - return tuple = false
--  - use_xpcall = false
--  - set_variables = false
--
-- You can use M:set_use_xpcall(true) or M:show_variables_in_trace(true)
-- to modify the stacktrace for the current instance of this module.
--
-- @field path: The path of the module to be required
-- @field tuple: whether status and module should be returned as a tuple, default is false

-- @return: if tuple is true, returns a tuple with the first value being the status of the call (true or false) and the second value being the module or nil if an error occurred. If tuple is false, returns the module or nil if an error occurred.

function M:require_module(path, tuple)
  tuple = tuple or false
	local use_xpcall = M:set_use_xpcall()
  local set_variables = M:show_variables_in_trace()
	local function error_handler(err)
		print("Error requiring module: " .. path)
    print("Timestamp: " .. os.date())
    print("Use pcall: " .. tostring(use_xpcall))
		print("Return tuple: " .. tostring(tuple))
    if set_variables then
      print("Variables at time of error:")
      for k, v in pairs(_G) do
        print("Variable: " .. k, "Value: " .. v)
        print(" ")
      end
    end
		print(debug.traceback(err, 2))
		return err
	end

  if use_xpcall then
    local status, module = xpcall(require, error_handler, path)
    if status then
      if tuple then
        return status, module
      else
        return module
      end
    else
      if tuple then
        return status, nil
      else
        return nil
      end
    end
  else
    local status, module = pcall(require, path)
    if status then
      if tuple then
        return status, module
      else
        return module
      end
    else
      if tuple then
        return status, nil
      else
        return nil
      end
    end
  end
end
--- The function split_str takes in three parameters:
--
-- @field inputstr: The inputstr parameter is the string that will be split
-- @field sep: The sep parameter is the separator used to split the string.
--             The default separator is whitespace.
-- @field pos: The pos parameter is an optional parameter that, if provided, will return
--             the element at the specified position in the resulting table of split strings.
--             If the position is out of bounds of the created table it will return the last
--             element by default
-- @return table of splitted strings, a specific string or false on fail
--
function M:split_str(inputstr, sep, pos)
	if sep == nil then
		sep = "%s"
	end

	pos = pos or false

	local t = {}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	if type(pos) == "boolean" and not pos then
		return t
	elseif pos then
		if pos <= #t then
			return t[pos]
		end
		return t[#t]
	else
		return t
	end
end

return M
