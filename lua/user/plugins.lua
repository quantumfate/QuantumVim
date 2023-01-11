local fn = vim.fn
-- Automatically install packer
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

-- Use a protected call so we don't error out on first use
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
  use("unblevable/quick-scope")
  use("tpope/vim-speeddating")
  use("tpope/vim-repeat")
  -- Easymotion -> specific plugins
  use("suy/vim-context-commentstring")
  use("RRethy/vim-illuminate")
  use("glts/vim-radical")

  use({ "asvetliakov/vim-easymotion", as = "vscode-easymotion", cond = vim.g.vscode })

  if vim.g.vscode == nil then
    use({ "easymotion/vim-easymotion", as = "nvim-easymotion", cond = vim.g.vscode == nil })
    use("goolord/alpha-nvim") -- greeter
    -- Colorschemes
    use("shaunsingh/nord.nvim")


    use("rcarriga/nvim-notify")

    -- language
    use("p00f/clangd_extensions.nvim")
    use("simrat39/rust-tools.nvim")
    use("mfussenegger/nvim-jdtls") -- java
    -- debugging
    use("nvim-lua/popup.nvim") -- An implementation of the Popup API from vim in Neovim
    use("mfussenegger/nvim-dap")
    -- LSP
    use("neovim/nvim-lspconfig") -- enable lsp
    use("williamboman/nvim-lsp-installer") -- simple to use language server installer
    use("tamago324/nlsp-settings.nvim") -- language server settings defined in json for
    use("jose-elias-alvarez/null-ls.nvim") -- for formatters and linters

    -- CMP
    use("ray-x/cmp-treesitter")
    use("tamago324/cmp-zsh")
    use("Shougo/deol.nvim")
    use("hrsh7th/cmp-buffer")
    use("hrsh7th/cmp-path")
    use("hrsh7th/cmp-cmdline")
    use("hrsh7th/nvim-cmp") -- Autocompletion plugin
    use("hrsh7th/cmp-nvim-lsp") -- LSP source for nvim-cmp
    use("hrsh7th/cmp-nvim-lua")
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
  end
  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
