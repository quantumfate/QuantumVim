local dap = {
    dependencies = { "mason-nvim-dap", "nvim-dap-virtual-text", "nvim-dap-ui" },
    event = "User FileOpened",
    lazy = true
}

return dap
