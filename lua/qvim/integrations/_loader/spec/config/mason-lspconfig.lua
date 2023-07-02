local mason_lspconfig = {
	cmd = { "LspInstall", "LspUninstall" },
	config = function()
		require("mason-lspconfig").setup({ qvim.lsp.installer.setup })

		-- automatic_installation is handled by lsp-manager
		local settings = require("mason-lspconfig.settings")
		settings.current.automatic_installation = false
	end,
	lazy = true,
	event = "User FileOpened",
}

return mason_lspconfig
