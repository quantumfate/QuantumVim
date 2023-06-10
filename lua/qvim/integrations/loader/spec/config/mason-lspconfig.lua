local mason_lspconfig = {
    cmd = { "LspInstall", "LspUninstall" },
    config = function()
        -- automatic_installation is handled by lsp-manager
        local settings = require "mason-lspconfig.settings"
        settings.current.automatic_installation = false
    end,
    lazy = true,
    event = "User FileOpened",
    dependencies = "mason.nvim",
}

return mason_lspconfig
