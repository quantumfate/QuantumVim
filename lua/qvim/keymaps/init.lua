---@class keymaps
local M = {}
local Log = require("qvim.integrations.log")
local meta = require("qvim.keymaps.meta")
local keymap_defaults = require("qvim.keymaps.keymap")
local default = require("qvim.keymaps.default")
local fn_t = require("qvim.utils.fn_t")
local util = require("qvim.keymaps.util")
local adapt = require("qvim.keymaps.adapters")

--- A global variable to track standalone keymaps
_G.g_yikes_current_standalone_bindings = {}
--- A global variable to track group keymaps
_G.g_yikes_current_group_bindings = {}
--- A local table for gathered keymaps

---Parses a binding to the `descripted_keymaps` table.
---@param descripted_keymaps table
---@param lhs string
---@param declaration table
---@param opts table further options for a keymap
local function parse_binding_to_descripted(descripted_keymaps, lhs, declaration, opts)
	local binding
	if opts then
		binding = meta.set_binding_mt(lhs, declaration, opts)
	else
		binding = meta.set_binding_mt(lhs, declaration)
	end

	local descriptor = tostring(binding)
	if descripted_keymaps[descriptor] then
		if descripted_keymaps[descriptor][lhs] then
			_G.g_yikes_current_standalone_bindings[lhs] = true
			descripted_keymaps[descriptor][lhs] = nil
		end
		descripted_keymaps[descriptor][lhs] = binding
		_G.g_yikes_current_standalone_bindings[lhs] = nil
	else
		descripted_keymaps[descriptor] = { [lhs] = binding }
	end
end

---Parses a group binding to the `descripted_keymaps` table.
---@param descripted_keymaps table
---@param declaration table
---@param bufnr number|nil
local function parse_group_to_descripted(descripted_keymaps, declaration, bufnr)
	local keymap_groups = meta.get_new_group_proxy_mt()
	local current_index = #keymap_groups + 1
	keymap_groups[current_index] = declaration
	local descriptor = tostring(keymap_groups[current_index])
	if descripted_keymaps[descriptor] then
		descripted_keymaps[descriptor] = nil
		Log:warn(string.format("An existing group '%s' will be overwritten.", descriptor))
	end
	descripted_keymaps[descriptor] = keymap_groups[current_index]
end

---Fetch keymaps from a given `bindings` to the proxy table `descripted_keymaps`.
---@param bindings table
---@param descripted_keymaps table
---@param bufnr number|nil allows to verride the buffer for individual keymaps
local function fetch_bindings(bindings, descripted_keymaps, bufnr)
	if fn_t.length(bindings) > 0 then
		for lhs, declaration in pairs(bindings) do
			if type(lhs) == "string" then
				-- binding
				parse_binding_to_descripted(descripted_keymaps, lhs, declaration, { buffer = bufnr })
			elseif type(lhs) == "number" and util.has_simple_group_structure(declaration) then
				-- group
				parse_group_to_descripted(descripted_keymaps, declaration, bufnr)
			else
				Log:error(
					string.format(
						"Unsupported key '%s' from type '%s' in keymaps init function.",
						tostring(lhs),
						type(lhs)
					)
				)
			end
		end
	else
		Log:debug(string.format("No keymaps defined for '%s'.", bindings))
	end
end

---Initializes the `qvim.keymaps` variable with from every configured integration.
function M:init()
	if _G.in_headless_mode() then
		Log:info("Headless mode detected. Not loading any keymappings.")
		return
	end

	local descripted_keymaps = meta.get_new_descriptor_proxy_mt()

	for vim_mode, bindings in pairs(keymap_defaults.get_defaults()) do
		local translated_mode = default.keymap_mode_adapters[vim_mode]
		for lhs, declaration in pairs(bindings) do
			parse_binding_to_descripted(descripted_keymaps, lhs, declaration, { mode = translated_mode })
		end
	end

	-- process keymaps declared by integrations
	for _, integration in ipairs(_G.qvim_integrations()) do
		if not _G.integration_provides_config(integration) then
			goto continue
		end

		local integration_keymaps = qvim.integrations[integration].keymaps

		if integration_keymaps then
			fetch_bindings(integration_keymaps, descripted_keymaps)
		else
			Log:debug("Integration '%s' has no keymaps.", integration)
		end
		::continue::
	end

	qvim.keymaps = vim.deepcopy(descripted_keymaps)
	Log:info("Keymaps were fetched and stored in qvim.keymaps!")
end

---Register bindings
---@param bufnr number|nil
---@param bindings table
function M:register(bufnr, bindings)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local descripted_keymaps = meta.get_new_descriptor_proxy_mt()
	fetch_bindings(bindings, descripted_keymaps, bufnr)

	adapt.setup(descripted_keymaps)
end

function M:setup()
	adapt.setup()
end

return M
