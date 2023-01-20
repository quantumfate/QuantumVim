require "lua.qvim.core.packer"
require "lua.qvim.core.impatient"
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






