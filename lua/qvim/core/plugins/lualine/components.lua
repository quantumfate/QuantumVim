local conditions = require("qvim.core.plugins.lualine.conditions")
---@type colors
local colors = require("qvim.core.plugins.lualine.util").get_colors()
---@type lualine_highlights
local highlights = require("qvim.core.plugins.lualine.highlights")
local util = require("qvim.core.plugins.lualine.util")
local fmt = string.format

local function diff_source()
    local gitsigns = vim.b.gitsigns_status_dict
    if gitsigns then
        return {
            added = gitsigns.added,
            modified = gitsigns.changed,
            removed = gitsigns.removed,
        }
    end
end

---@class lualine_components
---@field mode component
---@field branch component
---@field filename component
---@field diff component
---@field python_env component
---@field diagnostics component
---@field treesitter component
---@field lsp component
---@field copilot component
---@field location component
---@field progress component
---@field spaces component
---@field encoding component
---@field filetype component
---@field scrollbar component
---@field noice_recording component
return {
    mode = {
        "mode",
        padding = { left = 1, right = 1 },
        cond = nil,
        ---@param displayed string
        ---@param ctx table
        fmt = function(displayed, ctx)
            return util.unified_format(displayed, ctx)
        end
    },
    branch = {
        "b:gitsigns_head",
        icon = qvim.icons.git.Branch,
        fmt = function(displayed, ctx)
            local s = util.shorten_branch_name(displayed, 50)
            return util.unified_format(s, ctx)
        end
    },
    filename = {
        "filename",
    },
    diff = {
        "diff",
        source = diff_source,
        symbols = {
            added = qvim.icons.git.LineAdded .. " ",
            modified = qvim.icons.git.LineModified .. " ",
            removed = qvim.icons.git.LineRemoved .. " ",
        },
        padding = { left = 2, right = 1 },
        diff_color = {
            added = { fg = colors.green },
            modified = { fg = colors.yellow },
            removed = { fg = colors.red },
        },
        cond = nil,
    },
    python_env = {
        function()
            local utils = require("qvim.integrations.lualine.utils")
            if vim.bo.filetype == "python" then
                local venv = os.getenv("CONDA_DEFAULT_ENV") or os.getenv("VIRTUAL_ENV")
                if venv then
                    local icons = require("nvim-web-devicons")
                    local py_icon, _ = icons.get_icon(".py")
                    return string.format(" " .. py_icon .. " (%s)", utils.env_cleanup(venv))
                end
            end
            return ""
        end,
        cond = conditions.hide_in_width,
    },
    diagnostics = {
        "diagnostics",
        sources = { "nvim_diagnostic" },
        symbols = {
            error = qvim.icons.diagnostics.BoldError .. " ",
            warn = qvim.icons.diagnostics.BoldWarning .. " ",
            info = qvim.icons.diagnostics.BoldInformation .. " ",
            hint = qvim.icons.diagnostics.BoldHint .. " ",
        },
        cond = conditions.hide_in_width,
    },
    treesitter = {
        function()
            return qvim.icons.ui.Tree
        end,
        color = function()
            local buf = vim.api.nvim_get_current_buf()
            local ts = vim.treesitter.highlighter.active[buf]
            return { fg = ts and not vim.tbl_isempty(ts) and colors.green or colors.red }
        end,
        cond = conditions.hide_in_width,
    },
    lsp = {
        function()
            local buf_clients = vim.lsp.get_active_clients({ bufnr = vim.api.nvim_get_current_buf() })
            if #buf_clients == 0 then
                return highlights.ItemInactiveGreyLighterBg(qvim.icons.ui.LanguageServer)
            end

            -- add client
            local lsps = {}
            for _, client in pairs(buf_clients) do
                if client.name ~= "null-ls" and client.name ~= "copilot" then
                    table.insert(lsps, client.name)
                end
            end
            if #lsps == 0 then
                return highlights.ItemInactiveGreyLighterBg(qvim.icons.ui.LanguageServer)
            end
            return highlights.ItemActiveGreyLighterBg(qvim.icons.ui.LanguageServer) .. " " ..
                highlights.TextOneGreyLighterBg(util.unique_list_string_format(lsps))
        end,
        cond = function()
            return conditions.hide_in_width() --or conditions.no_clients()
        end,
        padding = { left = 1, right = 1 },
        separator = { left = highlights.ComponentSeparatorGreyLighterFgGreyBg(qvim.icons.ui.BoldCircleDividerRight) }

    },
    diagnostics_source = {
        function()
            local diagnostics = util.get_registered_methods("diagnostics")
            if #diagnostics == 0 or not diagnostics then
                return highlights.ItemInactiveGreyLighterBg(qvim.icons.ui.DiagnosticsSource)
            else
                return highlights.ItemActiveGreyLighterBg(qvim.icons.ui.DiagnosticsSource) ..
                    " " .. highlights.TextTwoGreyLighterBg(diagnostics)
            end
        end,
        cond = function()
            return conditions.hide_in_width() or conditions.no_clients()
        end,
        padding = { left = 1, right = 1 },
        separator = { left = highlights.ComponentSeparatorGreyLighterFgGreyBg(qvim.icons.ui.BoldCircleDividerRight) }
    },
    formatters_source = {
        function()
            local formatters = util.get_registered_methods("formatters")
            if #formatters == 0 or not formatters then
                return highlights.ItemInactiveGreyLighterBg(qvim.icons.ui.FormatterSource)
            else
                return highlights.ItemActiveGreyLighterBg(qvim.icons.ui.FormatterSource) ..
                    " " .. highlights.TextThreeGreyLighterBg(formatters)
            end
        end,
        cond = function()
            return conditions.hide_in_width() or conditions.no_clients()
        end,
        padding = { left = 1, right = 1 },
        separator = { left = highlights.ComponentSeparatorGreyLighterFgGreyBg(qvim.icons.ui.BoldCircleDividerRight) }
    },
    code_action_source = {
        function()
            local code_actions = util.get_registered_methods("code_actions")
            if #code_actions == 0 or not code_actions then
                return highlights.ItemInactiveGreyLighterBg(qvim.icons.ui.CodeActionSource)
            else
                return highlights.ItemActiveGreyLighterBg(qvim.icons.ui.CodeActionSource) ..
                    " " .. highlights.TextFourGreyLighterBg(code_actions)
            end
        end,
        cond = function()
            return conditions.hide_in_width() or conditions.no_clients()
        end,
        padding = { left = 1, right = 1 },
        separator = { left = highlights.ComponentSeparatorGreyLighterFgGreyBg(qvim.icons.ui.BoldCircleDividerRight) }
    },
    hover_source = {
        function()
            local hover = util.get_registered_methods("hover")
            if #hover == 0 or not hover then
                return highlights.ItemInactiveGreyLighterBg(qvim.icons.ui.HoverSource)
            else
                return highlights.ItemActiveGreyLighterBg(qvim.icons.ui.HoverSource) ..
                    " " .. highlights.TextFiveGreyLighterBg(hover)
            end
        end,
        cond = function()
            return conditions.hide_in_width() or conditions.no_clients()
        end,
        padding = { left = 1, right = 2 },
        separator = { left = highlights.ComponentSeparatorGreyLighterFgGreyBg(qvim.icons.ui.BoldCircleDividerRight) }
    },
    copilot = {
        function()
            local buf_clients = vim.lsp.get_active_clients({ bufnr = 0 })
            local copilot_active = false

            -- add client
            for _, client in pairs(buf_clients) do
                if client.name == "copilot" then
                    copilot_active = true
                end
            end

            local icon = highlights.ItemInactiveGreyBg(qvim.icons.git.Octoface)
            if copilot_active then
                icon = highlights.ItemActiveGreyBg(qvim.icons.git.Octoface)
            end

            return icon
        end,
        cond = function()
            return conditions.hide_in_width() or conditions.no_clients()
        end,
        padding = { left = 1, right = 1 },
        separator = {
            left = highlights.ComponentSeparatorGreyFgLighterGreyBg(qvim.icons.ui.BoldCircleDividerRight),
            right = { highlights.ComponentSeparatorGreyBg(qvim.icons.misc.Stars) }
        }

    },
    noice_rocording = {
        require("noice").api.statusline.mode.get,
        cond = require("noice").api.statusline.mode.has,
    },
    location = {
        "location",
        fmt = function(string, ctx)
            return fmt("%s", string)
        end,
        padding = { left = 1, right = 0 },
    },
    progress = {
        "progress",
        fmt = function()
            return "%P/%L"
        end,
    },

    spaces = {
        function()
            local shiftwidth = vim.api.nvim_buf_get_option(0, "shiftwidth")
            return qvim.icons.ui.Tab .. " " .. shiftwidth
        end,
        padding = 1,
    },
    encoding = {
        "o:encoding",
        fmt = string.upper,
        color = {},
        cond = conditions.hide_in_width,
    },
    filetype = {
        "filetype",
        cond = nil,
        padding = { left = 2, right = 2 },
    },
    scrollbar = {
        function()
            local current_line = vim.fn.line(".")
            local total_lines = vim.fn.line("$")
            local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
            local line_ratio = current_line / total_lines
            local index = math.ceil(line_ratio * #chars)
            return chars[index]
        end,
        padding = { left = 0, right = 0 },
        cond = nil,
    },
}
