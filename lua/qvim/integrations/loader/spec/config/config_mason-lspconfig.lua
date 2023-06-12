local mason_lspconfig = {
    cmd = { "LspInstall", "LspUninstall" },

    lazy = true,
    event = "User FileOpened",
    dependencies = "mason.nvim",
}

return mason_lspconfig
