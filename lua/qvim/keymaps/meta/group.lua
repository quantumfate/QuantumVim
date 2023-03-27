---@class group
local group = {}

local Log = require("qvim.integrations.log")
local default = require("qvim.keymaps.default")

local fn_t = require("qvim.utils.fn_t")

---@class util
local util = nil

---initializes the group module with the util factory
---@param _util util
---@return group
function group.init(_util)
    util = _util
    return group
end

group.mt = setmetatable({}, {
    __index = function(t, k)
        if type(k) == "string" then
            if k == "bindings" or k == "options" or rawget(t, k) ~= nil then
                return t[k]
            else
                if default.keymap_group[k] then
                    return default.keymap_group[k]
                else
                    Log:error(string.format("Failed to index '%s' with key '%s'. This key is not allowed.",
                    getmetatable(t), k))
                end
            end
        else
            Log:error(string.format("The key to a value in '%s' must be a string but was '%s'.", getmetatable(t), type(k)))
        end
    end,
    ---Ensures that values in a group have the correct metatable information or at least the defaults
    ---@param t table
    ---@param k string
    ---@param other table
    __newindex = function(t, k, other)
        if type(k) == "string" then
            if other then
                if k == "bindings" then
                    local keymaps = util.get_new_keymap_mt()

                    if type(other) == "table" then
                        for key, value in pairs(other) do
                            keymaps[key] = value
                        end
                    else
                        Log:debug(string.format(
                            "The value corresponding to '%s' must be a table but was '%s'. Value is now an empty table with meta information.",
                            k, type(other)))
                    end
                    fn_t.rawset_debug(t, k, keymaps)
                elseif k == "options" then
                    local options = setmetatable(other or {}, { __index = default.keymap_group_opts })
                    fn_t.rawset_debug(t, k, options)
                else
                    if type(other) == "string" then
                        fn_t.rawset_debug(t, k, other)
                    else
                        Log:debug(string.format(
                            "The value of '%s' must be a string but was '%s'. Defaults were applied.", k, type(other)))
                        fn_t.rawset_debug(t, k, default.keymap_group[k])
                    end
                end
            else
                if k == "bindings" then
                    fn_t.rawset_debug(t, k, util.get_new_keymap_mt())
                elseif k == "options" then
                    fn_t.rawset_debug(t, k, setmetatable({}, { __index = default.keymap_group_opts }))
                else
                    fn_t.rawset_debug(t, k, default.keymap_group[k])
                end
            end
        else
            Log:error(string.format("The key to a value in '%s' must be a string but was '%s'.", getmetatable(t), type(k)))
        end
    end,
    ---Returns a human readable representation of a group
    ---@param t table
    __tostring = function(t)
        local base = string.format(
            "%s::%s",
            "key_group=" .. t.key_group,
            "prefix=" .. t.prefix
        )
        base = base .. "::bindings={"
        if fn_t.length(t.bindings) > 0 then
            local transformed_keys = fn_t.transform_and_unpack(t.bindings, tostring, true)
            for index, initial_k in ipairs(transformed_keys) do
                base = base .. initial_k
                if index < #transformed_keys then
                    base = base .. ","
                end
            end
        end
        base = base .. "}"
        if t.options then
            base = base .. "::options={"
            local count = 0
            local length = fn_t.length(t.options)
            if length > 0 then
                for key, value in pairs(t.options) do
                    count = count + 1
                    base = base .. (key .. "=" .. value)
                    if count < length then
                        base = base .. ","
                    end
                end
            end
        end
        return base
    end
})

return group
