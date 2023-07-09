---The nordic configuration file
local M = {}

local Log = require "qvim.log"

---Registers the global configuration scope for nordic
function M:init()
    local nordic = {
        active = true,
        on_config_done = nil,
        keymaps = {},
        options = {
            theme = "nordic",
            -- Enable bold keywords.
            bold_keywords = true,
            -- Enable italic comments.
            italic_comments = true,
            -- Enable general editor background transparency.
            transparent_bg = false,
            -- Enable brighter float border.
            bright_border = true,
            -- Nordic specific options.
            -- Set all to false to use original Nord colors.
            -- Adjusts some colors to make the theme a bit nicer (imo).
            nordic = {
                -- Reduce the overall amount of blue in the theme (diverges from base Nord).
                reduced_blue = true,
            },
            -- Onedark specific options.
            -- Set all to false to keep original onedark colors.
            -- Adjusts some colors to make the theme a bit nicer (imo).
            -- WIP.
            onedark = {
                -- Brighten the whites to fit the theme better.
                brighter_whites = true,
            },
            -- Override the styling of any highlight group.
            override = {},
            cursorline = {
                -- Enable bold font in cursorline.
                bold = false,
                -- Avialable styles: 'dark', 'light'.
                theme = "light",
                -- Hide the cursorline when the window is not focused.
                hide_unfocused = true,
            },
            noice = {
                -- Available styles: `classic`, `flat`.
                style = "classic",
            },
            telescope = {
                -- Available styles: `classic`, `flat`.
                style = "flat",
            },
            leap = {
                -- Dims the backdrop when using leap.
                dim_backdrop = true,
            },
        },
    }
    return nordic
end

---The nordic setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
    local status_ok, nordic = pcall(reload, "nordic")
    if not status_ok then
        Log:warn(string.format("The plugin '%s' could not be loaded.", nordic))
        return
    end

    local _nordic = qvim.integrations.nordic
    nordic.setup(_nordic.options)

    nordic.load()

    if _nordic.on_config_done then
        _nordic.on_config_done()
    end
end

return M
