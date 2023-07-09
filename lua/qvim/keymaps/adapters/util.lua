---@class util
---@field get_mode function
---@field keymap_unpack function
---@field make_proxy_mutation_table function
---@field transform_rhs_and_desc_to_index function
local M = {}
local constants = require "qvim.keymaps.constants"

-- constants
local rhs = constants.neovim_options_constants.rhs
local desc = constants.neovim_options_constants.desc

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

---Creates a metatable on a given `binding` that maps the rhs and desc key
---to their respective index.
---@param binding table the table with the keys such as rhs, desc, mode, ...
---@param idx_rhs number the desired positional index for rhs
---@param idx_desc number the desired positional index for desc
function M.transform_rhs_and_desc_to_index(binding, idx_rhs, idx_desc)
    return setmetatable({}, {
        __index = function(_, k)
            if type(k) == "number" then
                if k == idx_rhs then
                    return rawget(binding, rhs)
                elseif k == idx_desc then
                    return rawget(binding, desc)
                end
            else
                return rawget(binding, k)
            end
        end,
    })
end

return M
