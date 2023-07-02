---@class qvim.lang.null-ls._meta
local M = {}
local _ = require("mason-core.functional")
local ft_map = require("null-ls.builtins._meta.filetype_map")
local null_ls = require("null-ls")
local Log = require("qvim.log")

local fmt = string.format

local ft_bridge = {
	["ansible"] = "yaml.ansible",
	["mdx"] = "markdown.mdx",
	["guile"] = "scheme.guile",
}

---Create a proxy table to to the null-ls builtin filetype map that maps some filetype exception to their corresponding null-ls managed filetype.
---The proxy table indexes `require("null-ls.builtins._meta.filetype_map")`
---
---See: https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/lua/null-ls/builtins/_meta/filetype_map.lua
---@return table
function M.ft_bridge()
	local proxy = {
		__index = function(_, v)
			if ft_bridge[v] then
				return ft_map[ft_bridge][v]
			else
				return ft_map[v]
			end
		end,
	}
	return setmetatable({}, proxy)
end

local method_bridge = {
	["formatting"] = null_ls.methods.FORMATTING,
	["diagnostics"] = null_ls.methods.DIAGNOSTICS,
	["code_actions"] = null_ls.methods.CODE_ACTION,
	["hover"] = null_ls.methods.HOVER,
	[null_ls.methods.FORMATTING] = null_ls.methods.FORMATTING,
	[null_ls.methods.DIAGNOSTICS] = null_ls.methods.DIAGNOSTICS,
	[null_ls.methods.CODE_ACTION] = null_ls.methods.CODE_ACTION,
	[null_ls.methods.HOVER] = null_ls.methods.HOVER,
}

---Returns a table that ensures the keys or values used for other tables will always be null-ls provided strings.
---@return table
function M.method_bridge()
	local proxy = {
		__index = function(_, v)
			if method_bridge[v] then
				return method_bridge[v]
			end
			Log:error(fmt("Invalid key '%s' for null-ls method bridge.", v))
		end,
	}
	return setmetatable({}, proxy)
end

local method_to_string_arg = {
	[null_ls.methods.FORMATTING] = "formatter",
	[null_ls.methods.DIAGNOSTICS] = "diagnostic",
	[null_ls.methods.CODE_ACTION] = "code_action",
	[null_ls.methods.HOVER] = "hover",
}

---Returns a table that ensures the keys or values used for other tables will always be null-ls provided strings.
---@return table
function M.method_to_string_arg()
	local proxy = {
		__index = function(_, v)
			if method_to_string_arg[v] then
				return method_to_string_arg[v]
			end
			Log:error(fmt("Invalid key '%s' for null-ls method to string arg bridge.", v))
		end,
	}
	return setmetatable({}, proxy)
end

return M
