local M = {}

M.base_meta_table = setmetatable({}, {
    __index = function(t, k)
        local default_values = {
            active = true,
            on_config_done = nil,
            whichkey_group = M.whichkey_group,
            whichkey = M.whichkey,
            keymaps = M.keymaps,
            options = {},
        }
        return default_values[k]
    end,
})

M.keymap_mode_meta = setmetatable({}, {
    __index = function(t, k)
        -- always deepcopy!
        local modes = vim.deepcopy(keymap_mode_adapters)
        for key, _ in pairs(modes) do
            modes[key] = nil
        end
        return modes[k]
    end
})

M.whichkey_group_meta = setmetatable({}, {
    __newindex = function(t, k, v)
        local group = {
            group = nil,
            leader = nil,
            bindings = M.keymap_mode_meta
        }
        rawset(group, k, v)
    end,
})

M.whichkey_group = setmetatable({}, {
    __index = function(t, k)
        return t[k]
    end,
    __newindex = function(t, k, v)
        local table = M.whichkey_group_meta
        rawset(table, k, v)
    end
})

M.whichkey = setmetatable({}, {
    __index = function(t, k)
        return t[k]
    end,
    __newindex = function(t, k, v)
        local table = M.keymap_mode_meta
        rawset(table, k, v)
    end
})

M.keymaps = setmetatable({}, {
    __index = function(t, k)
        return t[k]
    end,
    __newindex = function(t, k, v)
        rawset(t, k, v)
    end
})

return M
