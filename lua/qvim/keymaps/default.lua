---Enables logic across the keymap section and defines some
---defaults for certain settings.
---@class default
local default = {}

local constants = require("qvim.keymaps.constants")

-- Be careful when making changes to this file

default.valid_integration_defaults = {
    active = true,
    on_config_done = true,
    keymaps = true,
    options = true
}

default.valid_binding_opts = {
    [constants.neovim_options_constants.rhs]      = true,
    [constants.neovim_options_constants.desc]     = true,
    [constants.neovim_options_constants.mode]     = true,
    [constants.neovim_options_constants.noremap]  = true,
    [constants.neovim_options_constants.nowait]   = true,
    [constants.neovim_options_constants.silent]   = true,
    [constants.neovim_options_constants.script]   = true,
    [constants.neovim_options_constants.expr]     = true,
    [constants.neovim_options_constants.unique]   = true,
    [constants.neovim_options_constants.buffer]   = true,
    [constants.neovim_options_constants.callback] = true,
}

default.binding_opts = {
    [constants.neovim_options_constants.rhs]      = "",
    [constants.neovim_options_constants.desc]     = "",
    [constants.neovim_options_constants.mode]     = "n",
    [constants.neovim_options_constants.noremap]  = true,
    [constants.neovim_options_constants.nowait]   = false,
    [constants.neovim_options_constants.silent]   = true,
    [constants.neovim_options_constants.script]   = false,
    [constants.neovim_options_constants.expr]     = false,
    [constants.neovim_options_constants.unique]   = false,
    [constants.neovim_options_constants.buffer]   = 0,
    [constants.neovim_options_constants.callback] = nil
}

default.valid_keymap_group_opts = {
    [constants.binding_group_constants.key_name]          = true,
    [constants.binding_group_constants.key_binding_group] = true,
    [constants.binding_group_constants.key_prefix]        = true,
    [constants.binding_group_constants.key_bindings]      = true,
    [constants.binding_group_constants.key_options]       = true
}

default.keymap_group = {
    [constants.binding_group_constants.key_name]          = "",
    [constants.binding_group_constants.key_binding_group] = "",
    [constants.binding_group_constants.key_prefix]        = " ",
    [constants.binding_group_constants.key_bindings]      = {},
    [constants.binding_group_constants.key_options]       = default.keymap_group_opts
}

default.keymap_group_opts = {
    [constants.neovim_options_constants.mode]    = "n",
    [constants.neovim_options_constants.noremap] = true,
    [constants.neovim_options_constants.nowait]  = false,
    [constants.neovim_options_constants.silent]  = true,
    [constants.neovim_options_constants.unique]  = false,
    [constants.neovim_options_constants.buffer]  = 0,
}


return default
