---The indentline configuration file
local M = {}

local Log = require "qvim.log"

---Registers the global configuration scope for indentline
function M:init()
    -- HACK: work-around for https://github.com/lukas-reineke/indent-blankline.nvim/issues/59
    vim.wo.colorcolumn = "99999"
    vim.cmd [[highlight IndentBlanklineIndent1 guifg=#2e2e2e gui=nocombine]]
    vim.cmd [[highlight IndentBlanklineIndent2 guifg=#2e2e2e gui=nocombine]]
    vim.cmd [[highlight IndentBlanklineIndent3 guifg=#2e2e2e gui=nocombine]]
    vim.cmd [[highlight IndentBlanklineIndent4 guifg=#2e2e2e gui=nocombine]]
    vim.cmd [[highlight IndentBlanklineIndent5 guifg=#2e2e2e gui=nocombine]]
    vim.cmd [[highlight IndentBlanklineIndent6 guifg=#2e2e2e gui=nocombine]]
    vim.opt.list = true
    local indentline = {
        active = true,
        on_config_done = nil,
        keymaps = {},
        options = {
            -- indentline option configuration
            show_current_context = true,
            show_current_context_start = true,
            show_trailing_blankline_indent = false,
            show_first_indent_level = true,
            blankline_enabled = false,
            use_treesitter = true,
            blankline_char = "▏",
            space_char = "⋅",
            char_highlight_list = {
                "IndentBlanklineIndent1",
                "IndentBlanklineIndent2",
                "IndentBlanklineIndent3",
                "IndentBlanklineIndent4",
                "IndentBlanklineIndent5",
                "IndentBlanklineIndent6",
            },
            buftype_exclude = { "nofile", "prompt", "quickfix, :terminal" },
            context_patterns = {
                "class",
                "return",
                "function",
                "method",
                "^if",
                "^fi",
                "^while",
                "jsx_element",
                "^for",
                "^object",
                "^table",
                "block",
                "arguments",
                "if_statement",
                "else_clause",
                "jsx_element",
                "jsx_self_closing_element",
                "try_statement",
                "catch_clause",
                "import_statement",
                "operation_type",
            },
            filetype_exclude = {
                "help",
                "startify",
                "dashboard",
                "packer",
                "neogitstatus",
                "NvimTree",
                "Trouble",
                "toggleterm",
            },
        },
    }
    return indentline
end

---The indentline setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
    if in_headless_mode() then
        return
    end
    local status_ok, indentline = pcall(reload, "indent_blankline")
    if not status_ok then
        Log:warn(
            string.format("The plugin '%s' could not be loaded.", indentline)
        )
        return
    end

    local _indentline = qvim.integrations.indentline
    indentline.setup(_indentline.options)

    if _indentline.on_config_done then
        _indentline.on_config_done()
    end
end

return M
