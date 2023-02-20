local nvim_tree = {
    --config = function()
    --    re.quire("lvim.core.nvimtree").setup()
    --end,
    cmd = {
        "NvimTreeToggle",
        "NvimTreeOpen",
        "NvimTreeFocus",
        "NvimTreeFindFileToggle"
    },
    event = "User DirOpened",
}

return nvim_tree
