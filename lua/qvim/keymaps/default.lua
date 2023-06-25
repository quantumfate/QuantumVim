---Enables logic across the keymap section and defines some
---defaults for certain settings.
---@class default
---@field keymap_mode_adapters table holds abbreviated modes
---@field inverted_keymap_mode_adapters table holds human readable modes
---@field valid_integration_defaults table logic enabling table for integration defaults
---@field valid_binding_opts table logic enabling table for binding defaults
---@field binding_opts table holds default options for a binding
---@field valid_keymap_group_memebers table logic enabling table for keymap group member
---@field keymap_group_opts table holds the default options for the keymap group member 'options'
---@field keymap_group_members table holds the defaults for keymap group member
---@field valid_keymap_group_opts table logic enabling table for the keymap group member 'options'
local M = {}

---@class constants
local constants = require("qvim.keymaps.constants")

---@class keymap.table_util
local table_util = require("qvim.keymaps.table_util")

-- Be careful when making changes to this file

local error_message = "Attempt to modify read-only table"

local function new_index(t, key, value)
	error(error_message)
end

local keymap_mode_adapters = {
	insert_mode = "i",
	normal_mode = "n",
	visual_mode = "v",
	visual_block_mode = "x",
	command_mode = "c",
	operator_pending_mode = "o",
	term_mode = "t",
}

M.keymap_mode_adapters = table_util.read_only(keymap_mode_adapters, new_index)

local inverted_keymap_mode_adapters = {
	i = "insert_mode",
	n = "normal_mode",
	v = "visual_mode",
	x = "visual_block_mode",
	c = "command_mode",
	o = "operator_pending_mode",
	t = "term_mode",
}

M.inverted_keymap_mode_adapters = table_util.read_only(inverted_keymap_mode_adapters, new_index)

local valid_integration_defaults = {
	active = true,
	on_config_done = true,
	keymaps = true,
	options = true,
}

M.valid_integration_defaults = table_util.read_only(valid_integration_defaults, new_index)

local valid_binding_opts = {
	[constants.neovim_options_constants.rhs] = true,
	[constants.neovim_options_constants.desc] = true,
	[constants.neovim_options_constants.mode] = true,
	[constants.neovim_options_constants.noremap] = true,
	[constants.neovim_options_constants.nowait] = true,
	[constants.neovim_options_constants.silent] = true,
	[constants.neovim_options_constants.script] = true,
	[constants.neovim_options_constants.expr] = true,
	[constants.neovim_options_constants.unique] = true,
	[constants.neovim_options_constants.buffer] = true,
	[constants.neovim_options_constants.callback] = true,
	[constants.neovim_options_constants.ignore] = true,
}

M.valid_binding_opts = table_util.read_only(valid_binding_opts, new_index)

local binding_opts = {
	[constants.neovim_options_constants.rhs] = "",
	[constants.neovim_options_constants.desc] = "",
	[constants.neovim_options_constants.mode] = "n",
	[constants.neovim_options_constants.noremap] = true,
	[constants.neovim_options_constants.nowait] = false,
	[constants.neovim_options_constants.silent] = true,
	[constants.neovim_options_constants.script] = false,
	[constants.neovim_options_constants.expr] = false,
	[constants.neovim_options_constants.unique] = false,
	[constants.neovim_options_constants.buffer] = nil,
	[constants.neovim_options_constants.callback] = nil,
	[constants.neovim_options_constants.ignore] = nil,
}

M.binding_opts = table_util.read_only(binding_opts, new_index)

local valid_keymap_group_memebers = {
	[constants.binding_group_constants.key_name] = true,
	[constants.binding_group_constants.key_binding_group] = true,
	[constants.binding_group_constants.key_prefix] = true,
	[constants.binding_group_constants.key_bindings] = true,
	[constants.binding_group_constants.key_options] = true,
}

M.valid_keymap_group_memebers = table_util.read_only(valid_keymap_group_memebers, new_index)

local keymap_group_opts = {
	[constants.neovim_options_constants.mode] = "n",
	[constants.neovim_options_constants.noremap] = true,
	[constants.neovim_options_constants.nowait] = false,
	[constants.neovim_options_constants.silent] = true,
	[constants.neovim_options_constants.unique] = false,
	[constants.neovim_options_constants.buffer] = nil,
}

M.keymap_group_opts = table_util.read_only(keymap_group_opts, new_index)

local keymap_group_members = {
	[constants.binding_group_constants.key_name] = "",
	[constants.binding_group_constants.key_binding_group] = "",
	[constants.binding_group_constants.key_prefix] = "<leader>",
	[constants.binding_group_constants.key_bindings] = {},
	[constants.binding_group_constants.key_options] = keymap_group_opts,
}

M.keymap_group_members = table_util.read_only(keymap_group_members, new_index)

local valid_keymap_group_opts = {
	[constants.neovim_options_constants.mode] = true,
	[constants.neovim_options_constants.noremap] = true,
	[constants.neovim_options_constants.nowait] = true,
	[constants.neovim_options_constants.silent] = true,
	[constants.neovim_options_constants.unique] = true,
	[constants.neovim_options_constants.buffer] = true,
}

M.valid_keymap_group_opts = table_util.read_only(valid_keymap_group_opts, new_index)

return table_util.read_only(M, new_index)
