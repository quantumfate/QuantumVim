local M = {}

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
    table.insert(t,str)
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
  return false
end

return M
