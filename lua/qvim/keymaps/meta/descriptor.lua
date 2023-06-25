---@class descriptor
local descriptor = {}

local Log = require("qvim.integrations.log")
local shared_util = require("qvim.keymaps.util")
local fn_t = require("qvim.utils.fn_t")

---@class util
local util = nil

---initializes the binding module with the util factory
---@param _util util
---@return descriptor
function descriptor.init(_util)
	util = _util
	return descriptor
end

---The metatable to group keymaps by a descriptor.
descriptor.mt = {
	__index = function(t, _descriptor)
		if type(_descriptor) == "string" then
			return rawget(t, _descriptor)
		else
			error(string.format("The type of a descriptor must be string but was '%s'.", type(_descriptor)))
		end
	end,
	---A keymap table added to this table will filter the bindings filtered and grouped by the descriptor.
	---@param t table
	---@param _descriptor string
	---@param _keymaps table
	__newindex = function(t, _descriptor, _keymaps)
		if type(_descriptor) == "string" then
			if type(_keymaps) == "table" then
				shared_util.action_based_on_descriptor(_descriptor, function()
					fn_t.rawset_debug(t, _descriptor, util.process_keymap_mt(_descriptor, _keymaps))
				end, function()
					fn_t.rawset_debug(t, _descriptor, util.process_group_memeber_mt(t, _descriptor, _keymaps))
				end)
			else
				Log:error(
					string.format(
						"The value corresponding to a descriptor '%s' must be a table but was '%s'.",
						_descriptor,
						type(_keymaps)
					)
				)
			end
		else
			error(
				string.format(
					"The descriptor of the following keymap \n'%s'\n must be a string but was '%s'.",
					vim.inspect(_keymaps),
					type(_descriptor)
				)
			)
		end
	end,
}

return descriptor
