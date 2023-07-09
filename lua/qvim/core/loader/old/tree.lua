local nvim_tree = {
    cmd = {
        "NvimTreeToggle",
        "NvimTreeOpen",
        "NvimTreeFocus",
        "NvimTreeFindFileToggle",
    },
    event = "User DirOpened",
    config = function()
        require("qvim.integrations.tree"):setup()
    end,
}

return nvim_tree
