return {
    leader = "space",
    reload_config_on_save = true,
    colorscheme = "nightfox",
    transparent_window = false,
    format_on_save = {
        ---@usage boolean: format on save (Default: false)
        enabled = true,
        ---@usage pattern string pattern used for the autocommand (Default: '*')
        pattern = "*",
        ---@usage timeout number timeout in ms for the format request (Default: 1000)
        timeout = 1000,
        ---@usage filter func to select client
        --filter = require("lvim.lsp.utils").format_filter,
        -- TODO add mason-lspconfig
    },
    keys = {},
    integrations = {},
    use_icons = true,
    icons = require "qvim.icons",
    autocommands = {},
    lang = {
        -- https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
        "arduino",
        "bash",
        "comment",
        "c", "cpp", "cmake", "make",
        "lua",
        "vim", "help",
        "dockerfile",
        "diff",
        "git_rebase", "gitattributes", "gitcommit", "gitignore",
        "graphql",
        "html", "css",
        "http",
        "java", "kotlin",
        "javascript", "tsx",
        "json", "json5",
        "latex",
        "markdown", "markdown_inline",
        "python",
        "r",
        "rasi",
        "regex",
        "ruby",
        "rust",
        "sql",
        "toml",
        "yaml",
    },
    log = {
        ---@usage can be { "trace", "debug", "info", "warn", "error", "fatal" },
        level = "info",
        viewer = {
            ---@usage this will fallback on "less +F" if not found
            cmd = "qnav",
            layout_config = {
                ---@usage direction = 'vertical' | 'horizontal' | 'window' | 'float',
                direction = "horizontal",
                open_mapping = "",
                size = 40,
                float_opts = {},
            },
        },
        -- currently disabled due to instabilities
        override_notify = false,
    },
}
