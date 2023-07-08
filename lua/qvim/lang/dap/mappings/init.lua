---@class dap.mappings
---@field ft_to_dap table filetype mapped to debug adapter in mason-nvim-dap
---@field dap_to_ft table debug adapter mapped to filetype in mason-nvim-dap
---@field ft_to_mason_package table maps a ft to a mason debug adapter package
local M = {}
local _ = require("mason-core.functional")
local mason_nvim_dap_mappings = require("mason-nvim-dap.mappings.source")
local Log = require("qvim.log")
local fmt = string.format

M.ft_to_dap = {
	["python"] = "python",
	["delve"] = "delve",
	["php"] = "php",
	["coreclr"] = "coreclr",
	["js"] = "js",
	["c"] = "codelldb",
	["cpp"] = "codelldb",
	["bash"] = "bash",
	["mock"] = "mock",
	["puppet"] = "puppet",
	["eelixir"] = "elixir",
	["kotlin"] = "kotlin",
	["dart"] = "dart",
	["hls"] = "haskell",
}

M.dap_to_ft = _.invert(M.ft_to_dap)

M.ft_to_mason_package = setmetatable({}, {
	__index = function(_, k)
		if M.ft_to_dap[k] then
			return mason_nvim_dap_mappings.nvim_dap_to_package[M.ft_to_dap[k]]
		else
			Log:warn(fmt("No such filetype '%s' available for a debug adapter.", k))
		end
	end,
})

M.mason_package_to_ft = setmetatable({}, {
	__index = function(_, k)
		if mason_nvim_dap_mappings.package_to_nvim_dap[k] then
			return M.dap_to_ft[mason_nvim_dap_mappings.package_to_nvim_dap[k]]
		else
			Log:warn(fmt("No such mason package available '%s' for a debug adapter.", k))
		end
	end,
})

return M
