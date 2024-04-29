---@class Table
local Table = {}

local log = require("qvim.log").qvim
local fmt = string.format

---Join a table to a string with a delimiter.
---@param t table
---@param d string
---@return unknown
function Table.join(t, d)
	local count = #t
	if count == 1 then
		return t[1]
	end
	local s = ""
	for i, value in pairs(t) do
		s = i < count and s + value + d or s + value
	end
	return s
end

---Wraps Lua's builtin rawget. Calls rawget and prints debug information.
---@param t any
---@param k any
---@param s string? the name of the table or defaults to metatable type
---@return any
function Table.rawget_debug(t, k, s)
	s = s or tostring(getmetatable(t))
	log.debug(fmt("The key '%s' was referenced from the '%s' table.", k, s))
	return rawget(t, k)
end

---Wraps Lua's builtin rawset. Calls rawset and prints debug information.
---@param t any
---@param k any
---@param v any
---@param s string? the name of the table or defaults to metatable type
---@return table
function Table.rawset_debug(t, k, v, s)
	s = s or tostring(getmetatable(t))
	log.debug(fmt("Added the key '%s' to the '%s' table.", k, s))
	return rawset(t, k, v)
end

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

---Checks if any entry in a table satisfies a predicate
---@param t any
---@param predicate any
---@return boolean
function Table.any(t, predicate)
	for _, entry in pairs(t) do
		if predicate(entry) then
			return true
		end
	end
	return false
end

---Inverts the key and value pairs of the given table
---@param t table
---@return table
function Table.invert_table(t)
	local inverted_t = {}
	for key, value in pairs(t) do
		inverted_t[value] = key
	end
	return inverted_t
end

---Takes keys or values from a given table `tbl` and applies a transformation on either the keys or values
---specified by the function `transform_fn`.
---When `do_keys` is true the transformed value will be mapped to their initial keys otherwise the transformed keys will
---me mapped to a numerical index.
---@param tbl table the table to be unpacked
---@param transform_fn function
---@param do_keys boolean
---@return table
function Table.transform_to_table(tbl, transform_fn, do_keys)
	local transformed = {}
	for k, v in pairs(tbl) do
		if do_keys then
			transformed[#transformed + 1] = transform_fn(k)
		else
			transformed[k] = transform_fn(v)
		end
	end
	return transformed
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

---Counts the elements in a table regadless of their type
---@param t table
---@return integer
function Table.length(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

--- Check if the predicate returns True for at least one entry of the table.
-- @param t The table
-- @param predicate The function called for each entry of t
-- @return True if predicate returned True at least once, false otherwise
function Table.contains(t, predicate)
	return Table.find_first(t, predicate) ~= nil
end

return Table
