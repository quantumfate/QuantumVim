---@class constants
---@field binding_prefix string a prefix to denote binding descriptors
---@field binding_group_prefix string a prefix to denote key group descriptors
---@field binding_prefix_pt string a pattern to match binding descriptors
---@field binding_group_prefix_pt string a pattern to match key group descriptors
---@field rhs_index number the index in a binding for a right hand side
---@field desc_index number the index in a binding for description
---@field binding_group_constants binding_group_constants Constants for a binding group
---@field neovim_options_constants neovim_options_constants Constants for neovim specific options
local M = {}

local error_message = "Attempt to modify read-only table"

local function new_index(t, key, value)
	error(error_message)
end

---@class keymap.table_util
local table_util = require("qvim.keymaps.table_util")

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
---@field ignore string ignore
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
	callback = "callback",
	ignore = "ignore",
}

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

local constants = {
	binding_prefix = "binding=",
	binding_group_prefix = "binding_group=",
	binding_prefix_pt = "^binding=.*$",
	binding_group_prefix_pt = "^binding_group=.*$",
	rhs_index = 1,
	desc_index = 2,
	binding_group_constants = table_util.read_only(binding_group_constants, new_index),
	neovim_options_constants = table_util.read_only(neovim_options_constants, new_index),
}

M = table_util.read_only(constants, new_index)

return M
