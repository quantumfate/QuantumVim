local actions = require("qvim.utils.modules").require_on_exported_call("telescope.actions")
local builtin = require("qvim.utils.modules").require_on_exported_call("telescope.builtin")

---@class telescope : core_meta_parent
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field theme string the theme to use for the telescope preview
---@field extensions_to_load table<string>
---@field extensions table<string> a list of extension url's
---@field conf_extensions table<string, AbstractExtension> instances of configured extensions
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps table|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: telescope, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: telescope)|nil overwrite the setup function in core_meta_parent
---@field on_setup_done fun(self: telescope, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local telescope = {
    enabled = true,
    name = nil,
    theme = "dropdown",
    extensions = {
        "tsakirist/telescope-lazy.nvim",
        "nvim-telescope/telescope-file-browser.nvim",
        "nvim-telescope/telescope-dap.nvim",
        "nvim-telescope/telescope-project.nvim",
        "nvim-telescope/telescope-fzf-native.nvim",
    },
    conf_extensions = {},
    options = {
        defaults = {
            prompt_prefix = qvim.icons.ui.Telescope .. " ",
            selection_caret = qvim.icons.ui.Forward .. " ",
            entry_prefix = "  ",
            initial_mode = "insert",
            selection_strategy = "reset",
            sorting_strategy = nil,
            layout_strategy = nil,
            layout_config = {},
            vimgrep_arguments = {
                "rg",
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--smart-case",
                "--hidden",
                "--glob=!.git/",
            },
            ---@usage Mappings are fully customizable. Many familiar mapping patterns are setup as defaults.
            mappings = {
                i = {
                    ["<C-n>"] = actions.move_selection_next,
                    ["<C-p>"] = actions.move_selection_previous,
                    ["<C-c>"] = actions.close,
                    ["<C-j>"] = actions.cycle_history_next,
                    ["<C-k>"] = actions.cycle_history_prev,
                    ["<C-q>"] = function(...)
                        actions.smart_send_to_qflist(...)
                        actions.open_qflist(...)
                    end,
                    ["<CR>"] = actions.select_default,
                },
                n = {
                    ["<C-n>"] = actions.move_selection_next,
                    ["<C-p>"] = actions.move_selection_previous,
                    ["<C-q>"] = function(...)
                        actions.smart_send_to_qflist(...)
                        actions.open_qflist(...)
                    end,
                },
            },
            file_ignore_patterns = {},
            path_display = { "smart" },
            winblend = 0,
            border = {},
            borderchars = nil,
            color_devicons = true,
            set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
        },
        pickers = {
            find_files = {
                hidden = true,
            },
            live_grep = {
                --@usage don't include the filename in the search results
                only_sort_text = true,
            },
            grep_string = {
                only_sort_text = true,
            },
            buffers = {
                initial_mode = "normal",
                mappings = {
                    i = {
                        ["<C-d>"] = actions.delete_buffer,
                    },
                    n = {
                        ["dd"] = actions.delete_buffer,
                    },
                },
            },
            planets = {
                show_pluto = true,
                show_moon = true,
            },
            git_files = {
                hidden = true,
                show_untracked = true,
            },
            colorscheme = {
                enable_preview = true,
            },
        },
        extensions = {
            -- hooked from respective extension file
        },
    },
    extensions_to_load = {},
    keymaps = {
        --[[         {
            binding_group = "s",
            name = "Search",
            bindings = {
                ["cb"] = { rhs = "<cmd>Telescope git_branches<cr>", desc = "Checkout branch" },
                c = { rhs = "<cmd>Telescope colorscheme<cr>", desc = "Colorscheme" },
                h = { rhs = "<cmd>Telescope help_tags<cr>", desc = "Find Help" },
                M = { rhs = "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
                r = { rhs = "<cmd>Telescope oldfiles<cr>", desc = "Open Recent File" },
                R = { rhs = "<cmd>Telescope registers<cr>", desc = "Registers" },
                k = { rhs = "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
                C = { rhs = "<cmd>Telescope commands<cr>", desc = "Commands" },
                f = { rhs = "", desc = "Fuzzy find files", callback = builtin.find_files },
                l = { rhs = "", desc = "Live grep", callback = builtin.live_grep },
                b = { rhs = "", desc = "Show buffers", callback = builtin.buffers },
            },
            options = {
                prefix = "<leader>",
            },
        }, ]]
    },
    main = "telescope",
    ---@param self telescope
    on_setup_start = function(self, _)
        local previewers = require "telescope.previewers"
        local sorters = require "telescope.sorters"

        self.options = vim.tbl_extend("keep", {
            file_previewer = previewers.vim_buffer_cat.new,
            grep_previewer = previewers.vim_buffer_vimgrep.new,
            qflist_previewer = previewers.vim_buffer_qflist.new,
            file_sorter = sorters.get_fuzzy_file,
            generic_sorter = sorters.get_generic_fuzzy_sorter,
        }, self.options)

        local theme = require("telescope.themes")["get_" .. (self.theme or "")]
        if theme and type(theme) == "function" then
            self.options.defaults = theme(self.options.defaults)
        end
    end,
    setup = nil,
    ---@param self telescope
    ---@param telescope table
    on_setup_done = function(self, telescope)
        for _, extension in pairs(self.extensions_to_load) do
            print(extension)
            telescope.load_extension(extension)
        end
    end,
    url = "https://github.com/nvim-telescope/telescope.nvim",
}

telescope.__index = telescope

return telescope
