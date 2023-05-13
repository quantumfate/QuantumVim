---@class constants
---@field binding_prefix string a prefix to denote binding descriptors
---@field binding_group_prefix string a prefix to denote key group descriptors
---@field binding_prefix_pt string a pattern to match binding descriptors
---@field binding_group_prefix_pt string a pattern to match key group descriptors
---@field binding_group_constants binding_group_constants Constants for a binding group
---@field neovim_options_constants neovim_options_constants Constants for neovim specific options
local M = {}

local error_message = "Attempt to modify read-only table"

---@class neovim_options_constants
---@field rhs string right hand side
---@field desc string keybind description
---@field mode string neovim mode
---@field noremap string noremap
---@field nowait string nowait
---@field silent string silent
---@field script string script
---@field expr string expr
---@field unique string unique
---@field buffer string buffer
---@field callback string callback
local neovim_options_constants = {
    rhs = "rhs",
    desc = "desc",
    mode = "mode",
    noremap = "noremap",
    nowait = "nowait",
    silent = "silent",
    script = "script",
    expr = "expr",
    unique = "unique",
    buffer = "buffer",
    callback = "callback"
}

setmetatable(neovim_options_constants, {
    __newindex = function(t, key, value)
        error(error_message)
    end
})

---@class binding_group_constants
---@field key_name string Descriptive name for a binding group
---@field key_binding_group string Key to be pressed to activate a binding group
---@field key_prefix string A prefix that enables binding groups - usually the leader key
---@field key_bindings string Binds of a binding group
---@field key_options string global options specific for a binding group
local binding_group_constants = {
    key_name = "name",
    key_binding_group = "binding_group",
    key_prefix = "prefix",
    key_bindings = "bindings",
    key_options = "options",
}

setmetatable(binding_group_constants, {
    __newindex = function(t, key, value)
        error(error_message)
    end
})

local constants = {
    binding_prefix = "binding=",
    binding_group_prefix = "binding_group=",
    binding_prefix_pt = "^binding=.*$",
    binding_group_prefix_pt = "^binding_group=.*$",
    binding_group_constants = binding_group_constants,
    neovim_options_constants = neovim_options_constants,
}

-- Make the constants table read-only by using a metatable
local mt = {
    __newindex = function(t, key, value)
        error(error_message)
    end,
    __index = constants
}

setmetatable(M, mt)

return M