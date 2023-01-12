local status_mason_ok, mason = pcall(require, "mason")
if not status_mason_ok then
  return
end

local status_mason_ok, properties = pcall(require, "properties")
if not status_mason_ok then
  return
end

local setup = {
  -- Language Server
  "mason-lspconfig" = properties.servers,
  "mason-nvim-dap" = properties.debuggers,
  "mason-null-ls" = properties.builtins,
}


mason.setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})


