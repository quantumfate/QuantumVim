local status_mason_ok, mason = pcall(require, "mason")
if not status_mason_ok then
  return
end

properties = require("user.languages.utils.properties")

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


