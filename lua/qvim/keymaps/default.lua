---@class default
local default = {}

default.valid_integration_defaults = {
    active = true,
    on_config_done = true,
    keymaps = true,
    options = true
}

default.valid_keymap_opts = {
    rhs = true,
    desc = true,
    mode = true,
    noremap = true,
    nowait = true,
    silent = true,
    script = true,
    expr = true,
    unique = true,
    buffer = true,
    callback = true,
}

default.keymap_opts = {
    rhs = "",
    desc = "",
    mode = "n",
    noremap = true,
    nowait = false,
    silent = true,
    script = false,
    expr = false,
    unique = false,
    buffer = 0,
    callback = function()

    end,
}

default.valid_keymap_group_opts = {
    name = true,
    key_group = true,
    prefix = true,
    bindings = true
}

default.keymap_group_opts = {
    name = "",
    key_group = "",
    prefix = "",
    bindings = nil
}
return default
