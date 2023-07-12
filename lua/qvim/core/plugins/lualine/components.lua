local conditions = require("qvim.core.plugins.lualine.conditions")
---@class colors
local colors = require("qvim.core.plugins.lualine.util").get_colors()

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

local branch = qvim.icons.git.Branch

if qvim.config.colorscheme == "catppuccin" then
    branch = "%#SLGitIcon#" .. qvim.icons.git.Branch .. "%*" .. "%#SLBranchName#"
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
---@field location component
---@field progress component
---@field spaces component
---@field encoding component
---@field filetype component
---@field scrollbar component
return {
    mode = {
        "mode",
        padding = { left = 1, right = 1 },
        cond = nil,
    },
    branch = {
        "b:gitsigns_head",
        icon = branch,
    },
    filename = {
        "filename",
        color = {},
        cond = nil,
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
            local buf_clients = vim.lsp.get_active_clients({ bufnr = 0 })
            if #buf_clients == 0 then
                return "LSP Inactive"
            end

            local buf_ft = vim.bo.filetype
            local buf_client_names = {}
            local copilot_active = false

            -- add client
            for _, client in pairs(buf_clients) do
                if client.name ~= "null-ls" and client.name ~= "copilot" then
                    table.insert(buf_client_names, client.name)
                end

                if client.name == "copilot" then
                    copilot_active = true
                end
            end

            local formatters = require("qvim.lang.null-ls.methodservice.formatters")
            local supported_formatters = formatters:list_registered(buf_ft)
            vim.list_extend(buf_client_names, supported_formatters)

            local diagnostics = require("qvim.lang.null-ls.methodservice.diagnostics")
            local supported_diagnostics = diagnostics:list_registered(buf_ft)
            vim.list_extend(buf_client_names, supported_diagnostics)

            local code_actions = require("qvim.lang.null-ls.methodservice.code_actions")
            local supported_code_actions = code_actions:list_registered(buf_ft)
            vim.list_extend(buf_client_names, supported_code_actions)

            local hover = require("qvim.lang.null-ls.methodservice.hover")
            local supported_hover = hover:list_registered(buf_ft)
            vim.list_extend(buf_client_names, supported_hover)

            local make_unique = function(list)
                local unique_list = {}
                for _, item in pairs(list) do
                    if not vim.tbl_contains(unique_list, item) then
                        table.insert(unique_list, item)
                    end
                end
                return unique_list
            end
            local unique_client_names = table.concat(make_unique(buf_client_names), ", ")
            local language_servers = string.format("[%s]", unique_client_names)

            if copilot_active then
                language_servers = language_servers .. " " .. qvim.icons.git.Octoface .. " "
            end

            return language_servers
        end,
        cond = conditions.hide_in_width,
    },
    location = {
        "location",
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
        color = "SLProgress",
        cond = nil,
    },
}
