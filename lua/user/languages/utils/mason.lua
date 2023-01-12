local status_mason_ok, mason = pcall(require, "mason")
if not status_mason_ok then
  return
end

local status_properties_ok, properties = pcall(require, "properties")
if not status_properties_ok then
  return
end

local setup = {
  -- Language Server
  masonlspconfig = properties.servers,
  masonnvimdap = properties.debuggers,
  masonnullls = properties.builtins,
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


