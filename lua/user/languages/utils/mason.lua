local status_mason_ok, mason = pcall(require, "mason")
if not status_mason_ok then
  return
end

mason.setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

for i, lsp_server in pairs(properties.servers) do
  vim.api.nvim_command("MasonInstall ".. lsp_server)
end
