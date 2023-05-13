---@class whichkey
local M = {}

local util = require("qvim.keymaps.adapters.util")
local fn = require("qvim.utils.fn")
local shared_util = require("qvim.keymaps.util")
local constants = require("qvim.keymaps.constants")

local rhs = constants.neovim_options_constants.rhs
local desc = constants.neovim_options_constants.desc
local group_binding_trigger = constants.binding_group_constants.key_binding_group
local group_name = constants.binding_group_constants.key_name
local group_bindings = constants.binding_group_constants.key_bindings
local group_opts = constants.binding_group_constants.key_options
local group_prefix = constants.binding_group_constants.key_prefix
---Formats a table of binidngs into a whichkey formfactor for fast processing.
---@param descriptors_t table
---@param binding_descriptor string
---@return table<table, table>
local function mutation_for_single_binding(descriptors_t, binding_descriptor)
    local keymaps = descriptors_t[binding_descriptor]
    local whichkey_mappings = {}
    local _opts = nil
    for lhs, opts in pairs(keymaps) do
        if not _opts then
            _opts = fn.shallow_table_copy(opts)
        end
        _opts[rhs], _opts[desc] = nil, nil
        whichkey_mappings[lhs] = { opts[rhs], opts[desc] }
    end
    return { whichkey_mappings, _opts }
end

local function mutation_for_group_binding(descriptors_t, group_descriptor)
    local group = descriptors_t[group_descriptor]
    local _group = fn.shallow_table_copy(group)
    local whichkey_group = {}
    local whichkey_group_opts = _group[group_opts]
    for lhs, _ in pairs(_group[group_bindings]) do
        local temp_rhs, temp_desc = _group[group_bindings][lhs][rhs], _group[group_bindings][lhs][desc]
        _group[group_bindings][lhs][rhs], _group[group_bindings][lhs][desc] = nil, nil
        _group[group_bindings][lhs][0] = temp_rhs
        _group[group_bindings][lhs][1] = temp_desc
    end
    whichkey_group[_group[group_binding_trigger]] = _group[group_bindings]
    whichkey_group[_group[group_binding_trigger]][group_name] = _group[group_name]

    whichkey_group_opts[group_prefix] = group[group_prefix]

    return { whichkey_group, whichkey_group_opts }
end

---Adapt keymaps for whichkey
---@param whichkey table The whichkey instance
function M.adapt(whichkey)
    local _whichkey = qvim.integrations.whichkey
    whichkey.setup(_whichkey.options)

    for descriptor, _ in pairs(qvim.keymaps) do
        shared_util.action_based_on_descriptor(
            descriptor,
            function()
                local proxy = util.make_proxy_mutation_table(qvim.keymaps, mutation_for_single_binding)
                local mutated_keymappings = proxy[descriptor]
                whichkey.register(
                    mutated_keymappings[#mutated_keymappings - 1],
                    mutated_keymappings[#mutated_keymappings]
                )
            end,
            function()
                local proxy = util.make_proxy_mutation_table(qvim.keymaps, mutation_for_group_binding)
                local mutaged_group = proxy[descriptor]
                whichkey.register(
                    mutaged_group[#mutaged_group - 1],
                    mutaged_group[#mutaged_group]
                )
            end
        )
    end
end

return M
