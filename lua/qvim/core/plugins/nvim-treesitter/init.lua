---@generic T
---@class nvim-treesitter : core_meta_parent
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field extensions table<string> a list of extension url's
---@field conf_extensions table<string, AbstractExtension> instances of configured extensions
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps table|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: nvim-treesitter, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: nvim-treesitter)|nil overwrite the setup function in core_meta_parent
---@field on_setup_done fun(self: nvim-treesitter, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local nvim_treesitter = {
    enabled = true,
    name = nil,
    extensions = {},
    conf_extensions = {},
    options = {
        ensure_installed = { "comment", "markdown_inline", "regex", "dap_repl" },

        -- List of parsers to ignore installing (for "all")
        ignore_install = {},

        -- A directory to install the parsers into.
        -- By default parsers are installed to either the package dir, or the "site" dir.
        -- If a custom path is used (not nil) it must be added to the runtimepath.
        parser_install_dir = nil,

        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- Automatically install missing parsers when entering buffer
        auto_install = true,

        matchup = {
            enable = false, -- mandatory, false will disable the whole extension
            -- disable = { "c", "ruby" },  -- optional, list of language that will be disabled
        },
        highlight = {
            enable = true, -- false will disable the whole extension
            additional_vim_regex_highlighting = false,
            disable = function(lang, buf)
                if vim.tbl_contains({ "latex" }, lang) then
                    return true
                end

                local status_ok, big_file_detected =
                    pcall(vim.api.nvim_buf_get_var, buf, "bigfile_disable_treesitter")
                return status_ok and big_file_detected
            end,
        },

        indent = { enable = true, disable = { "yaml", "python" } },
        autotag = { enable = false },
    },
    keymaps = {
        --[[         {
            name = "+Treesitter",
            binding_group = "T",
            bindings = {},
            options = {
                prefix = "<leader>",
            },
        }, ]]
    },
    main = "nvim-treesitter.configs",
    on_setup_start = nil,
    setup = nil,
    on_setup_done = nil,
    url = "https://github.com/nvim-treesitter/nvim-treesitter",
}

nvim_treesitter.__index = nvim_treesitter

return nvim_treesitter
