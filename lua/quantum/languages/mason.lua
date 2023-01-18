local utils = require("quantum.utils.util")
local mason = utils:require_module("mason")

mason.setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})
