---@class meta
local meta = {}

local keymap = require("qvim.keymaps.meta.keymap")


local Log = require("qvim.integrations.log")
local fn = require("qvim.utils.fn")
local fn_t = require("qvim.utils.fn_t")
local default = require("qvim.keymaps.default")

meta.default_values = {
    active = true,
    on_config_done = nil,
    keymaps = {},
    options = {},
}

--- The metatable for integration options.
meta.integration_opts_mt = setmetatable({}, {
    ---Returns the the value for `t[idx]`. If any of the default options are not present it will be initialised.
    ---@param t any
    ---@param idx any
    ---@return boolean|table|nil
    __index = function(t, idx)
        if default.valid_integration_defaults[idx] and not t[idx] then
            return meta.default_values[idx]
        else
            return t[idx]
        end
    end,
    __newindex = function(t, opt, value)
        Log:debug(string.format("Adding option '%s'."), opt)
        t[opt] = value
    end
})

--- The metatable for integrations and their defined base.
meta.integration_base_mt = setmetatable({}, {
    __index = function(t, name)
        return t[fn.normalize(name)]
    end,
    __newindex = function(t, name, options)
        print("is this calsseds")
        local _name = fn.normalize(name)
        Log:debug(string.format("Processing configuration for '%s'.", _name))
        t[name] = options
    end,
})

return meta
