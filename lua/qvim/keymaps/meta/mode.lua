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

local modes = vim.deepcopy(keymap_mode_adapters)

---The meta table that holds values grouped by keymap mode adapters
mode.mt = setmetatable({}, {
    ---A key added to this table has to be one of the accepted mode adapters
    ---@param t table
    ---@param mode_adapter string
    ---@param descriptor table
    __newindex = function(t, mode_adapter, descriptor)
        if type(descriptor) == "string" then
            for _mode_adapter, _ in pairs(modes) do
                modes[_mode_adapter] = true
            end
            if modes[mode_adapter] then
                fn_t.rawset_debug(t, mode_adapter, descriptor)
            else
                Log:error(string.format("Invalid mode adapter '%s'", mode_adapter))
            end
        else
            Log:error(string.format("The value corresponding to the mode adapter '%s' must be a string but is '%s'.",
                type(descriptor)))
        end
    end
})


return mode
