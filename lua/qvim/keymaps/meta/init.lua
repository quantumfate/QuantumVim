---@class meta
local meta = {}

local binding = require("qvim.keymaps.meta.binding")
local group = require("qvim.keymaps.meta.group")
local keymap = require("qvim.keymaps.meta.keymap")
local util = require("qvim.keymaps.meta.util")
    .init(
        binding,
        group,
        keymap
    )

binding.init(util)
group.init(util)
keymap.init(util)


local Log = require("qvim.integrations.log")


---The meta table that holds values grouped by keymap mode adapters
meta.mode_adapter_mt = setmetatable({}, {
    ---A key added to this table has to be one of the accepted mode adapters
    ---@param t table
    ---@param mode_adapter string
    ---@param other_keymap_t table
    __newindex = function(t, mode_adapter, other_keymap_t)
        if type(other_keymap_t) == "table" then
            local modes = vim.deepcopy(keymap_mode_adapters)
            for _mode_adapter, _ in pairs(modes) do
                modes[_mode_adapter] = true
            end
            if modes[mode_adapter] then
                t[mode_adapter] = util.get_new_keymap_mt(other_keymap_t)
            else
                Log:error(string.format("Invalid mode adapter '%s'", other_keymap_t))
            end
        else
            Log:error(string.format("The value corresponding to the mode adapter '%s' must be a table.", mode_adapter))
        end
    end
})

return meta
