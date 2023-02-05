local telescope = {
    branch = "0.1.x",
    config = function()
        require("lvim.core.telescope").setup()
    end,
    dependencies = { "telescope-fzf-native.nvim" },
    lazy = true,
    cmd = "Telescope",
}

return telescope
