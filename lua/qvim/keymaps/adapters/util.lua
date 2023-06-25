---@class util
local M = {}

--- credits: https://github.com/folke/which-key.nvim
function M.get_mode()
	local mode = vim.api.nvim_get_mode().mode
	return mode:lower()
end

---Unpacks a keymap.
---@param lhs string
---@param binding table
---@return string mode, string lhs, string rhs, table options
function M.keymap_unpack(lhs, binding)
	local options = {}
	for key, value in pairs(binding) do
		if key ~= "mode" and key ~= "rhs" then
			options[key] = value
		end
	end
	return binding.mode, lhs, binding.rhs, options
end

---Creates a proxy table of a given `origin` and mutates the data by a given
---function `mutation`. The mutation will be called upon indexing the returned
---table `proxy` by intercepting `origin` as the first argument and `key` of the
---inner `__index` method as the second argument.
---@param origin table the table that holds the data
---@param mutation function the function to mutate the data
---@return table proxy the proxy table to be indexed
function M.make_proxy_mutation_table(origin, mutation)
	return setmetatable({}, {
		__index = function(_, key)
			return mutation(origin, key)
		end,
	})
end

return M
