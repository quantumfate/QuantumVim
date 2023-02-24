function _G.deepcopy(orig)
    local copy
    if type(orig) == "table" then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function _G.in_headless_mode()
    return #vim.api.nvim_list_uis() == 0
end

---Replaces hyphons with underscores in a string
---@param val string
function _G.normalize(val)
    return val:gsub("-", "_")
end
