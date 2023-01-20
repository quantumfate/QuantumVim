local utils = require("qvim.utils.util")
utils:set_use_xpcall(true)
require "lua.qvim.core.packer"
--require "qvim.impatient"
require "lua.qvim.core.keymap"
require "lua.qvim.core.options"
if vim.g.vscode then
  -- VSCode extension
  require "qvim.vscode"
else
  require "lua.qvim.core.alpha"
  require "qvim.integrations"
  require "qvim.languages"
end





