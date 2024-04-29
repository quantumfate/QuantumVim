---@class dap.mappings
---@field ft_to_mason_dap_package table
---@field mason_dap_package_to_ft table
---@field ft_to_mason_test_package table
---@field mason_test_package_to_ft table
local M = {}

local log = require("qvim.log").dap
local _ = require("mason-core.functional")
local mason_nvim_dap_mappings = require("mason-nvim-dap.mappings.source")
local fmt = string.format

local ft_to_dap = {
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

local dap_to_ft = _.invert(ft_to_dap)

local extended_ft_to_dap = {
	["java"] = "java-debug-adapter",
}

local extended_dap_to_ft = _.invert(extended_ft_to_dap)

local ft_to_test = {
	["java"] = "java-test",
}

local test_to_ft = _.invert(ft_to_test)

M.ft_to_mason_dap_package = setmetatable({}, {
	__index = function(_, k)
		if ft_to_dap[k] then
			return mason_nvim_dap_mappings.nvim_dap_to_package[ft_to_dap[k]]
		elseif extended_ft_to_dap[k] then
			return extended_ft_to_dap[k]
		else
			log.debug(
				fmt("No such filetype '%s' available for a debug adapter.", k)
			)
		end
	end,
})

M.mason_dap_package_to_ft = setmetatable({}, {
	__index = function(_, k)
		if mason_nvim_dap_mappings.package_to_nvim_dap[k] then
			return dap_to_ft[mason_nvim_dap_mappings.package_to_nvim_dap[k]]
		elseif extended_dap_to_ft[k] then
			return extended_dap_to_ft[k]
		else
			log.debug(
				fmt(
					"No such mason package available '%s' for a debug adapter.",
					k
				)
			)
		end
	end,
})

M.ft_to_mason_test_package = setmetatable({}, {
	__index = function(_, k)
		if ft_to_test[k] then
			return ft_to_test[k]
		else
			log.debug(
				fmt("No such filetype '%s' available for a debug adapter.", k)
			)
		end
	end,
})

M.mason_test_package_to_ft = setmetatable({}, {
	__index = function(_, k)
		if test_to_ft[k] then
			return test_to_ft[k]
		else
			Log.warn(
				fmt(
					"No such mason package available '%s' for a debug adapter.",
					k
				)
			)
		end
	end,
})

return M
