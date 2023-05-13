---@class binding
local binding = {}

local default = require("qvim.keymaps.default")
local constants = require("qvim.keymaps.constants")
---@class util
local util = nil

---initializes the binding module with the util factory
---@param _util util
---@return binding
function binding.init(_util)
    util = _util
    return binding
end

--- The meta table that maps an index function to retrieve
--- the default keymap options. It implements an `__eq` meta method
--- to allow comparing of right hand side bindings.
binding.mt = {
    ---Merges default options with user defined options stored in the table
    ---@param t table the indexed table
    ---@param opt string
    ---@return boolean|string|integer|function|nil
    __index = function(t, opt)
        if default.valid_binding_opts[opt] then
            return rawget(t, opt) --or default.binding_opts[opt]
        else
            error(string.format("Invalid option '%s' for binding.", opt))
            return nil
        end
    end,
    ---Set an value for a supported option and fill with defaults
    ---@param t table
    ---@param opt string
    ---@param setting function|boolean|string|integer|nil
    __newindex = function(t, opt, setting)
        if default.valid_binding_opts[opt] then
            rawset(t, opt, setting)
        else
            error(string.format("Invalid option '%s' for binding.", opt))
        end
    end,
    ---Checks for equality in keymappings. Two keymaps with a different buffer value are not considered equal.
    ---@param t1 table
    ---@param t2 table
    ---@return boolean
    __eq = function(t1, t2)
        if t1.buffer and t2.buffer and t1.buffer ~= t2.buffer then
            return false
        end
        local function is_function(v) return type(v) == "function" end
        for k, v in pairs(t1) do
            if not is_function(v) and t2[k] ~= v then
                return false
            end
        end
        for k, v in pairs(t2) do
            if not is_function(v) and t1[k] ~= v then
                return false
            end
        end
        return true
    end,
    __tostring = function(t)
        return string.format(
            constants.binding_prefix .. "%s::%s::%s::%s::%s::%s::%s::%s",
            constants.neovim_options_constants.mode .. "=" .. t.mode,
            constants.neovim_options_constants.noremap .. "=" .. tostring(t.noremap),
            constants.neovim_options_constants.nowait .. "=" .. tostring(t.nowait),
            constants.neovim_options_constants.silent .. "=" .. tostring(t.silent),
            constants.neovim_options_constants.script .. "=" .. tostring(t.script),
            constants.neovim_options_constants.expr .. "=" .. tostring(t.expr),
            constants.neovim_options_constants.unique .. "=" .. tostring(t.unique),
            constants.neovim_options_constants.buffer .. "=" .. tostring(t.buffer)
        )
    end
}

return binding
