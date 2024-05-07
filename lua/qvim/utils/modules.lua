local M = {}

local log = require("qvim.log").qvim
local fmt = string.format
-- revisit this
-- function prequire(package)
--   local status, lib = pcall(require, package)
--   if status then
--     return lib
--   else
--     vim.notify("Failed to require '" .. package .. "' from " .. debug.getinfo(2).source)
--     return nil
--   end
-- end

---Assigns the key of a new table to the old table. Existing entries
---in the old table may be overridden. In case of a type mismatch the
---entries will still be overridden but a warning will be called.
---
---@param old table the old table
---@param new table the new table
---@param k any the key of the respective table
local function _assign(old, new, k)
	local otype = type(old[k])
	local ntype = type(new[k])
	if
		(otype == "thread" or otype == "userdata")
		or (ntype == "thread" or ntype == "userdata")
	then
		vim.notify(
			fmt("warning: old or new attr %s type be thread or userdata", k)
		)
	end
	old[k] = new[k]
end

---Replaces the the values of the old table with the values
---in the new table. When the key, value pair in the new table
---doesn't exist, it will be deleted from the old table. This
---function works recursively and if the type is a table it will
---enter the recursion and if it is not it will call the replace
---function instead to to overwrite the old entries with the
---new ones
---
--- TODO: optionally keep old data
---
---If there is a type mismatch between the keys it will overwrite
---the old type with the new type.
---
---@param old table the entries of the old table
---@param new table the entries of the new table
---@param repeat_tbl table a flag table to keep track of processed entries where the key maps to booleans
local function _replace(old, new, repeat_tbl)
	if repeat_tbl[old] then
		-- return when an entry was already processed
		return
	end
	repeat_tbl[old] = true

	-- if a key from the old table does not exist in the new table
	-- it will be deleted from the old table
	local dellist = {}
	for k, _ in pairs(old) do
		if not new[k] then
			table.insert(dellist, k)
		end
	end
	-- deleting
	for _, v in ipairs(dellist) do
		old[v] = nil
	end

	-- iterate the new table
	for k, _ in pairs(new) do
		if not old[k] then
			old[k] = new[k]
		else
			if type(old[k]) ~= type(new[k]) then
				log.debug(
					fmt(
						"Reloader: mismatch between old [%s] and new [%s] type for [%s]",
						type(old[k]),
						type(new[k]),
						k
					)
				)
				_assign(old, new, k)
			else
				if type(old[k]) == "table" then
					-- recurse
					_replace(old[k], new[k], repeat_tbl)
				else
					-- overwrite
					_assign(old, new, k)
				end
			end
		end
	end
end

--- Requires a module and clears any chached state of the module.
--- If the require of the module failed the cached state of the
--- module will be preserved.
---@param m table the module that should be clean required
---@return table module the clean required module on success else the old module before require
M.require_clean = function(m)
	package.loaded[m] = nil
	_G[m] = nil
	local _, module = pcall(require, m)
	return module
end

---Requires a module using the pcall statement
---@param mod string the path to the module
---@return table|boolean module the module's table or false on failed pcall
M.require_safe = function(mod)
	local status_ok, module = pcall(require, mod)
	if not status_ok then
		local trace = debug.getinfo(2, "SL")
		local shorter_src = trace.short_src
		local lineinfo = shorter_src
			.. ":"
			.. (trace.currentline or trace.linedefined)
		local msg = fmt("%s : skipped loading [%s]", lineinfo, mod)
		log.debug(msg)
		return status_ok
	end
	return module
end

--- Requires a module and clears any chached state of the module.
--- If the require of the module failed the cached state of the
--- module will be preserved. If a module was not required yet
--- it will be required and this function returns immediately.
---@param mod string the path to the module
---@return table|boolean module the clean required module on success else the old module before require or false
M.reload = function(mod)
	if not package.loaded[mod] then
		return M.require_safe(mod)
	end

	local old = package.loaded[mod]
	package.loaded[mod] = nil
	local new = M.require_safe(mod)

	if type(old) == "table" and type(new) == "table" then
		local repeat_tbl = {}
		_replace(old, new, repeat_tbl)
	end

	package.loaded[mod] = old
	return old
end

--- Require on index.
---
--- Will only require the module after the first index of a module.
--- Only works for modules that export a table.
function M.require_on_index(require_path)
	-- code from <https://github.com/tjdevries/lazy-require.nvim/blob/bb626818ebc175b8c595846925fd96902b1ce02b/lua/lazy-require.lua#L25>
	return setmetatable({}, {
		__index = function(_, key)
			return require(require_path)[key]
		end,

		__newindex = function(_, key, value)
			require(require_path)[key] = value
		end,
	})
end

--- Require when an exported method is called.
---
--- Creates a new function. Cannot be used to compare functions,
--- set new values, etc. Only useful for waiting to do the require until you actually
--- call the code.
---
--- <pre>
--- -- This is not loaded yet
--- local lazy_mod = lazy.require_on_exported_call('my_module')
--- local lazy_func = lazy_mod.exported_func
---
--- -- ... some time later
--- lazy_func(42)  -- <- Only loads the module now
---
--- </pre>
function M.require_on_exported_call(require_path)
	-- https://github.com/tjdevries/lazy-require.nvim/blob/bb626818ebc175b8c595846925fd96902b1ce02b/lua/lazy-require.lua#L64
	return setmetatable({}, {
		__index = function(_, k)
			return function(...)
				return require(require_path)[k](...)
			end
		end,
	})
end

return M
