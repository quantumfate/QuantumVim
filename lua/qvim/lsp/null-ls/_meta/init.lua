local M = {}

local ft_map = require("null-ls.builtins._meta.filetype_map")

local ft_bridge = {
    ["ansible"] = "yaml.ansible",
    ["mdx"] = "markdown.mdx",
    ["guile"] = "scheme.guile"
}

---Create a proxy table to to the null-ls builtin filetype map that maps some filetype exception to their corresponding null-ls managed filetype.
---The proxy table indexes `require("null-ls.builtins._meta.filetype_map")`
---
---See: https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/lua/null-ls/builtins/_meta/filetype_map.lua
---@return table
function M.ft_bridge()
    local proxy = {
        __index = function(_, v)
            if ft_bridge[v] then
                return ft_map[ft_bridge][v]
            else
                return ft_map[v]
            end
        end,
    }
    return setmetatable({}, proxy)
end

return M
