local dap = {
    dependencies = { "mason-nvim-dap", "nvim-dap-virtual-text", "nvim-dap-ui", "cmp-dap", "nvim-dap-repl-highlights" },
    event = "User FileOpened",
    lazy = true
}

return dap
