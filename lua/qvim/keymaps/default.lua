---Enables logic across the keymap section and defines some
---defaults for certain settings.
---@class default
local default = {}

-- Be careful when making changes to this file

default.valid_integration_defaults = {
    active = true,
    on_config_done = true,
    keymaps = true,
    options = true
}

default.valid_binding_opts = {
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

default.binding_opts = {
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
    callback = nil
}

default.valid_keymap_group_opts = {
    name = true,
    key_group = true,
    prefix = true,
    bindings = true,
    options = true
}

default.keymap_group = {
    name = "",
    key_group = "",
    prefix = " ",
    bindings = {},
    options = default.keymap_group_opts
}

default.keymap_group_opts = {
    mode = "n",
    noremap = true,
    nowait = false,
    silent = true,
    unique = false,
    buffer = 0,
}


return default
