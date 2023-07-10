---@class core
local core = {}

local fmt = string.format
local log = require "qvim.log"
---@class util
local util = require "qvim.core.util"
---@class core_base
local core_base = require "qvim.core.base"
---@class core_loader
local core_loader = require "qvim.core.loader"

core.plugins = {
    "goolord/alpha-nvim",
    "akinsho/bufferline.nvim",
    "SmiteshP/nvim-navic",
    "nvim-tree/nvim-web-devicons",
    "b0o/schemastore.nvim",
    "numToStr/Comment.nvim",
    "mfussenegger/nvim-jdtls",
    "mfussenegger/nvim-dap",
    "hrsh7th/nvim-cmp",
    "rcarriga/cmp-dap",
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
    "LiadOz/nvim-dap-repl-highlights",
    "RRethy/vim-illuminate",
    "lukas-reineke/indent-blankline.nvim",
    "lewis6991/gitsigns.nvim",
    "neovim/nvim-lspconfig",
    "williamboman/mason.nvim",
    "jay-babu/mason-nvim-dap.nvim",
    "jay-babu/mason-null-ls.nvim",
    "williamboman/mason-lspconfig.nvim",
    "jose-elias-alvarez/null-ls.nvim",
    "nvim-lualine/lualine.nvim",
    "L3MON4D3/LuaSnip",
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
    "kyazdani42/nvim-tree.lua",
    "ahmedkhalf/project.nvim",
    "folke/neodev.nvim",
    "rcarriga/nvim-notify",
    "akinsho/toggleterm.nvim",
    "windwp/nvim-autopairs",
    "nvim-treesitter/nvim-treesitter",
    "Tastyep/structlog.nvim",
    "lervag/vimtex",
    "folke/which-key.nvim",
    "mfussenegger/nvim-dap-python",
    "nvim-neotest/neotest",
    "nvim-neotest/neotest-python",
    "stevearc/dressing.nvim",
    "AckslD/swenv.nvim",
    "p00f/clangd_extensions.nvim",
    "lewis6991/hover.nvim",
    "smoka7/hop.nvim",
    "catppuccin/nvim",
    "utilyre/barbecue.nvim",
    "zbirenbaum/copilot.lua",
    "ThePrimeagen/refactoring.nvim",
}

---Populates the global table `qvim.plugins` with all the plugin specs that
---are specified in `core.plugins` with their corresponding configuration in
---`qvim.core.plugins`.
function core.init_plugin_configurations()
    util.qvim_process_plugins(core_base.new)
    log:debug(
        fmt(
            "[core] Global qvim plugins table initialized. It total: '%s'",
            util.plugins_tbl_size()
        )
    )
end

---Fetches a complete lazy spec for all specified plugins with configuration and
---setup functions.
---@return table lazy_spec
function core.load_lazy_spec()
    local lazy_spec = util.lazy_process_plugins(core_loader.new, false)
    log:debug(
        fmt(
            "[core] Lazy spec initialized. Total plugins (without dependencies): %s",
            #lazy_spec
        )
    )
    return lazy_spec
end

---Fetches a light minimal lazy spec for all specified plugins solely meant for
---updates and first time setups of neovim.
---@return table lazy_spec_minimal
function core.load_lazy_spec_light()
    local lazy_spec_minimal = util.lazy_process_plugins(core_loader.new, true)
    log:debug(
        fmt(
            "[core] Minimal lazy spec initialized. Total plugins (without dependencies): %s",
            #lazy_spec_minimal
        )
    )
    return lazy_spec_minimal
end

return core
