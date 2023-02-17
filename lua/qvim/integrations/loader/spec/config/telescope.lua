local telescope = {
    dependencies = {
        "tsakirist/telescope-lazy.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make"
        },
        "nvim-lua/plenary.nvim" },
    lazy = true,
    cmd = "Telescope",
}

return telescope
