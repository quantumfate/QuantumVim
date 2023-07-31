---@class ts_util
local ts_util = {}

---Hooks the extension `self` into telescope
---@param self AbstractExtension
function ts_util.hook_extension_options(self)
	---@type nvim-treesitter
	local nvim_treesitter = getmetatable(self).__index
	nvim_treesitter.options[self.main] = self.options
end

return ts_util
