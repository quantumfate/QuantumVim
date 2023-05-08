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
        if type(mode_adapter) == "string" then
            for _mode_adapter, _ in pairs(modes) do
                modes[_mode_adapter] = true
            end
            if type(descriptor) == "string" or type(descriptor) == "table" then

            end
        end
    end
})


return mode
