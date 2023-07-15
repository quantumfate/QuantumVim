local lualine_util = {}

---@return colors
function lualine_util.get_colors()
    ---@class colors
    ---@field	rosewater string
    ---@field	flamingo string
    ---@field	pink string
    ---@field	mauve string
    ---@field	red string
    ---@field	maroon string
    ---@field	peach string
    ---@field	yellow string
    ---@field	green string
    ---@field	teal string
    ---@field	sky string
    ---@field	sapphire string
    ---@field	blue string
    ---@field	lavender string
    ---@field	text string
    ---@field	subtext1 string
    ---@field	subtext0 string
    ---@field	overlay2 string
    ---@field	overlay1 string
    ---@field	overlay0 string
    ---@field	surface2 string
    ---@field	surface1 string
    ---@field	surface0 string
    ---@field	base string
    ---@field	mantle string
    ---@field	crust string
    return require("catppuccin.palettes").get_palette("mocha")
end

function lualine_util.env_cleanup(venv)
    if string.find(venv, "/") then
        local final_venv = venv
        for w in venv:gmatch("([^/]+)") do
            final_venv = w
        end
        venv = final_venv
    end
    return venv
end

---@param displayed string
---@param ctx table
function lualine_util.unified_format(displayed, ctx)
    return displayed:lower()
end

---@param branch_name string
---@param max_length number
---@return string
function lualine_util.shorten_branch_name(branch_name, max_length)
    if #branch_name <= max_length then
        return branch_name
    end

    local parts = {}
    for part in string.gmatch(branch_name, "([^-%/]+)") do
        table.insert(parts, part)
    end

    if #parts == 1 then
        return branch_name:sub(1, max_length) .. "..."
    end

    local new_branch_name = ""
    for i, part in ipairs(parts) do
        if #new_branch_name + #part > max_length then
            break
        end
        new_branch_name = new_branch_name .. (i > 1 and "-" or "") .. part
    end

    return new_branch_name .. "..."
end

return lualine_util
