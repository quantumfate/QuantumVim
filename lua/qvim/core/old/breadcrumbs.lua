---The breadcrumbs configuration file
local M = {}

local Log = require "qvim.log"

local icons = qvim.icons.kind
---Registers the global configuration scope for breadcrumbs
function M:init()
    local breadcrumbs = {
        active = true,
        on_config_done = nil,
        keymaps = {},
        winbar_filetype_exclude = {
            "help",
            "startify",
            "dashboard",
            "lazy",
            "neo-tree",
            "neogitstatus",
            "NvimTree",
            "Trouble",
            "alpha",
            "lir",
            "Outline",
            "spectre_panel",
            "toggleterm",
            "DressingSelect",
            "Jaq",
            "harpoon",
            "dap-repl",
            "dap-terminal",
            "dapui_console",
            "dapui_hover",
            "lab",
            "notify",
            "noice",
            "neotest-summary",
            "",
        },
        options = {
            -- breadcrumbs option configuration
            icons = {
                Array = icons.Array .. " ",
                Boolean = icons.Boolean .. " ",
                Class = icons.Class .. " ",
                Color = icons.Color .. " ",
                Constant = icons.Constant .. " ",
                Constructor = icons.Constructor .. " ",
                Enum = icons.Enum .. " ",
                EnumMember = icons.EnumMember .. " ",
                Event = icons.Event .. " ",
                Field = icons.Field .. " ",
                File = icons.File .. " ",
                Folder = icons.Folder .. " ",
                Function = icons.Function .. " ",
                Interface = icons.Interface .. " ",
                Key = icons.Key .. " ",
                Keyword = icons.Keyword .. " ",
                Method = icons.Method .. " ",
                Module = icons.Module .. " ",
                Namespace = icons.Namespace .. " ",
                Null = icons.Null .. " ",
                Number = icons.Number .. " ",
                Object = icons.Object .. " ",
                Operator = icons.Operator .. " ",
                Package = icons.Package .. " ",
                Property = icons.Property .. " ",
                Reference = icons.Reference .. " ",
                Snippet = icons.Snippet .. " ",
                String = icons.String .. " ",
                Struct = icons.Struct .. " ",
                Text = icons.Text .. " ",
                TypeParameter = icons.TypeParameter .. " ",
                Unit = icons.Unit .. " ",
                Value = icons.Value .. " ",
                Variable = icons.Variable .. " ",
            },
            highlight = true,
            separator = " " .. qvim.icons.ui.ChevronRight .. " ",
            depth_limit = 0,
            depth_limit_indicator = "..",
        },
    }

    return breadcrumbs
end

---The breadcrumbs setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
    if in_headless_mode() then
        return
    end
    local status_ok, breadcrumbs = pcall(reload, "nvim-navic")
    if not status_ok then
        Log:warn(
            string.format("The plugin '%s' could not be loaded.", breadcrumbs)
        )
        return
    end

    local _breadcrumbs = qvim.integrations.breadcrumbs
    breadcrumbs.setup(_breadcrumbs.options)

    if _breadcrumbs.on_config_done then
        _breadcrumbs.on_config_done()
    end
end

M.get_filename = function()
    local filename = vim.fn.expand "%:t"
    local extension = vim.fn.expand "%:e"
    local f = require "qvim.utils.fn"

    if not f.isempty(filename) then
        local file_icon, hl_group
        local devicons_ok, devicons = pcall(require, "nvim-web-devicons")
        if qvim.use_icons and devicons_ok then
            file_icon, hl_group =
                devicons.get_icon(filename, extension, { default = true })

            if f.isempty(file_icon) then
                file_icon = qvim.icons.kind.File
            end
        else
            file_icon = ""
            hl_group = "Normal"
        end

        local buf_ft = vim.bo.filetype

        if buf_ft == "dapui_breakpoints" then
            file_icon = qvim.icons.ui.Bug
        end

        if buf_ft == "dapui_stacks" then
            file_icon = qvim.icons.ui.Stacks
        end

        if buf_ft == "dapui_scopes" then
            file_icon = qvim.icons.ui.Scopes
        end

        if buf_ft == "dapui_watches" then
            file_icon = qvim.icons.ui.Watches
        end

        if buf_ft == "dapui_console" then
            file_icon = qvim.icons.ui.DebugConsole
        end

        local navic_text = vim.api.nvim_get_hl_by_name("Normal", true)
        vim.api.nvim_set_hl(0, "Winbar", { fg = navic_text.foreground })

        return " "
            .. "%#"
            .. hl_group
            .. "#"
            .. file_icon
            .. "%*"
            .. " "
            .. "%#Winbar#"
            .. filename
            .. "%*"
    end
end

local get_gps = function()
    local status_gps_ok, gps = pcall(require, "nvim-navic")
    if not status_gps_ok then
        return ""
    end

    local status_ok, gps_location = pcall(gps.get_location, {})
    if not status_ok then
        return ""
    end

    if not gps.is_available() or gps_location == "error" then
        return ""
    end

    if not require("qvim.utils.fn").isempty(gps_location) then
        return "%#NavicSeparator#"
            .. qvim.icons.ui.ChevronRight
            .. "%* "
            .. gps_location
    else
        return ""
    end
end

local excludes = function()
    return vim.tbl_contains(
        qvim.integrations.breadcrumbs.winbar_filetype_exclude or {},
        vim.bo.filetype
    )
end

M.get_winbar = function()
    if excludes() then
        return
    end
    local f = require "qvim.utils.fn"
    local value = M.get_filename()

    local gps_added = false
    if not f.isempty(value) then
        local gps_value = get_gps()
        value = value .. " " .. gps_value
        if not f.isempty(gps_value) then
            gps_added = true
        end
    end

    if not f.isempty(value) and f.get_buf_option "mod" then
        -- TODO: replace with circle
        local mod = "%#LspCodeLens#" .. qvim.icons.ui.Circle .. "%*"
        if gps_added then
            value = value .. " " .. mod
        else
            value = value .. mod
        end
    end

    local num_tabs = #vim.api.nvim_list_tabpages()

    if num_tabs > 1 and not f.isempty(value) then
        local tabpage_number = tostring(vim.api.nvim_tabpage_get_number(0))
        value = value .. "%=" .. tabpage_number .. "/" .. tostring(num_tabs)
    end

    local status_ok, _ = pcall(
        vim.api.nvim_set_option_value,
        "winbar",
        value,
        { scope = "local" }
    )
    if not status_ok then
        return
    end
end

M.create_winbar = function()
    vim.api.nvim_create_augroup("_winbar", {})
    vim.api.nvim_create_autocmd({
        "CursorHoldI",
        "CursorHold",
        "BufWinEnter",
        "BufFilePost",
        "InsertEnter",
        "BufWritePost",
        "TabClosed",
        "TabEnter",
    }, {
        group = "_winbar",
        callback = function()
            if qvim.integrations.breadcrumbs.active then
                local status_ok, _ =
                    pcall(vim.api.nvim_buf_get_var, 0, "lsp_floating_window")
                if not status_ok then
                    -- TODO:
                    require("qvim.integrations.breadcrumbs").get_winbar()
                end
            end
        end,
    })
end

return M
