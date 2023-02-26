---@class Table
local Table = {}

--- Find the first entry for which the predicate returns true.
---@param t table
---@param predicate function function called for each entry of t
---@return any|nil entry for which the predicate returned True or nil
function Table.find_first(t, predicate)
  for _, entry in pairs(t) do
    if predicate(entry) then
      return entry
    end
  end
  return nil
end

---Checks if a table contains a key
---@param t table
---@param find any
---@param recurse boolean?
---@return boolean
function Table.has_any_key(t, find, recurse)
  if recurse == nil then
    recurse = false
  end
  for key, _ in pairs(t) do
    if key == find then
      return true
    end
    if type(t[key]) == "table" and recurse then
      if Table.has_any_key(t[key], find, recurse) then
        return true
      end
    end
  end
  return false
end

---Checks if a table contains a value
---@param t table
---@param find any
---@param recurse boolean?
---@return boolean
function Table.has_any_value(t, find, recurse)
  if recurse == nil then
    recurse = false
  end
  for _, entry in pairs(t) do
    if entry == find then
      return true
    end
    if type(entry) == "table" and recurse then
      if Table.has_any_value(entry, find, recurse) then
        return true
      end
    end
  end
  return false
end

--- Check if the predicate returns True for at least one entry of the table.
-- @param t The table
-- @param predicate The function called for each entry of t
-- @return True if predicate returned True at least once, false otherwise
function Table.contains(t, predicate)
  return Table.find_first(t, predicate) ~= nil
end

return Table
