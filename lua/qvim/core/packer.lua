local fn = vim.fn -- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	print("Installing packer close and reopen Neovim...")
	vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use local status_ok, packer = pcall(require, "packer")
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

-- Install your plugins here
--
--
-- Plugins listed in order of init.lua
return packer.startup(function(use)
	-- global plugins
	use("wbthomason/packer.nvim") -- Have packer manage itself

	use("lewis6991/impatient.nvim")
	use({
		"numToStr/Comment.nvim", -- Easily comment stuff
		tag = "v0.6",
	})
	use("tpope/vim-speeddating")
	use("tpope/vim-repeat")
	use("suy/vim-context-commentstring")
	use("RRethy/vim-illuminate")
	use("glts/vim-radical")

	use({
		"phaazon/hop.nvim",
		branch = "v2", -- optional but strongly recommended
	})
	use("goolord/alpha-nvim") -- greeter
	-- Colorschemes
	use("shaunsingh/nord.nvim")

	use("rcarriga/nvim-notify")
	use({
		"mrded/nvim-lsp-notify",
		requires = { "rcarriga/nvim-notify" },
	})
	use("lervag/vimtex")
	--[[ 
    Language,
    Linters,
    Formatter,
    Debugging
    ]]
	-- Integration management
	use({
		"williamboman/mason.nvim",
		requires = {
			"WhoIsSethDaniel/mason-tool-installer.nvim", -- Manage and update tools installed from mason
			"williamboman/mason-lspconfig.nvim", -- LSP Config injecter and LSP Install
			"jayp0521/mason-null-ls.nvim", -- Automatically install null-ls packages
			"RubixDev/mason-update-all", -- Adds convenient update all to mason
			"jayp0521/mason-nvim-dap", -- Install debugger packages autocmatically
		},
	})
	-- language
	use({
		"p00f/clangd_extensions.nvim",
		"simrat39/rust-tools.nvim",
		"mfussenegger/nvim-jdtls", -- java
		requires = "neovim/nvim-lspconfig",
	})
	-- debugging
	use({
		"mfussenegger/nvim-dap",
		"nvim-lua/popup.nvim", -- An implementation of the Popup API from vim in Neovim
	})

	-- LSP
	use({
		"neovim/nvim-lspconfig", -- enable lsp
		"tamago324/nlsp-settings.nvim", -- language server settings defined in json for
		"jose-elias-alvarez/null-ls.nvim", -- for formatters and linters
		requires = "nvim-lua/plenary.nvim",
	})
	-- CMP
	use({
		"ray-x/cmp-treesitter",
		"tamago324/cmp-zsh",
		"Shougo/deol.nvim",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/nvim-cmp", -- Autocompletion plugin
		"hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
		"hrsh7th/cmp-nvim-lua",
	})
	-- For vsnip users.
	use("hrsh7th/cmp-vsnip")
	use("hrsh7th/vim-vsnip")
	-- For lua scnip users
	use("L3MON4D3/LuaSnip") --snippet engine
	use("saadparwaiz1/cmp_luasnip") -- Snippets source for nvim-cmp
	--For snippy users.
	use("dcampos/nvim-snippy")
	use("dcampos/cmp-snippy")
	-- For ultisnips users.
	use("SirVer/ultisnips")
	use("quangnguyen30192/cmp-nvim-ultisnips")

	--
	use("antoinemadec/FixCursorHold.nvim") -- This is needed to fix lsp doc highlight
	use("folke/which-key.nvim")
	use("rafamadriz/friendly-snippets") -- a bunch of snippets to use
	-- Telescope
	use({
		"nvim-telescope/telescope.nvim",
		requires = use("nvim-lua/plenary.nvim"),
	}) -- Useful lua functions used by lots of plugins
	use("nvim-telescope/telescope-file-browser.nvim")
	use("nvim-telescope/telescope-media-files.nvim")
	use("ahmedkhalf/project.nvim")

	-- Treesitter
	use("kyazdani42/nvim-tree.lua")
	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
	})
	use("JoosepAlviste/nvim-ts-context-commentstring")

	-- Editor
	use("windwp/nvim-autopairs") -- Autopairs, integrates with both cmp and treesitter
	use("lukas-reineke/indent-blankline.nvim")
	use("akinsho/toggleterm.nvim")
	use("nvim-lualine/lualine.nvim")
	use({ "akinsho/bufferline.nvim", tag = "*", requires = "kyazdani42/nvim-web-devicons" })
	use("lewis6991/gitsigns.nvim")
	-- bbye
	use("moll/vim-bbye")
	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("lua.qvim.core.packer").sync()
	end
end)
