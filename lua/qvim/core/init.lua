---@class core
local core = {}

local log = require("qvim.log")
local utils = require("qvim.core.util")
---@class base
local base = require("qvim.core.base")

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
	"EdenEast/nightfox.nvim",
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
	"AlexvZyl/nordic.nvim",
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
  for _, url in pairs(core.plugins) do
    local name_ok, plugin_name = utils.is_valid_plugin_name(url)
    if name_ok and plugin_name then
      qvim.plugins[plugin_name] = base.new(plugin_name)
    else
      log:debug("The plugin url '%s' did not pass the plugin name validation. Na configuration or setup will be called.", url)
    end
  end
end

function core.load_lazy_spec()
  
end

return core
