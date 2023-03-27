---@class mode
local mode = {}

local fn_t = require("qvim.utils.fn_t")
local Log = require("qvim.integrations.log")
---@class util
local util = nil

---initializes the mode module with the util factory
---@param _util util
---@return mode
function mode.init(_util)
    util = _util
    return mode
end

---The meta table that holds values grouped by keymap mode adapters
mode.mt = setmetatable({}, {
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
                local keymaps = util.process_keymap_mt(mode_adapter, other_keymap_t)
                fn_t.rawset_debug(t, mode_adapter, keymaps)
            else
                Log:error(string.format("Invalid mode adapter '%s'", other_keymap_t))
            end
        else
            Log:error(string.format("The value corresponding to the mode adapter '%s' must be a table.", mode_adapter))
        end
    end
})


return mode
