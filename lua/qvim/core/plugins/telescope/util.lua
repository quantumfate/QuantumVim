local telescope_util = {}

---Hooks the extension `self` into telescope
---@param self AbstractExtension
function telescope_util.hook_extension(self)
    ---@type telescope
    local telescope = getmetatable(self).__index
    telescope.options.extensions[self.main] = self.options
    table.insert(telescope.extensions_to_load, self.main)
end

return telescope_util
