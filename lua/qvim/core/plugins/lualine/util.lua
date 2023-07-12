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

return lualine_util
