require "quantum.packer"
require "quantum.impatient"
require "quantum.keymap"
require "quantum.options"
if vim.g.vscode then
  -- VSCode extension
  require "quantum.vscode"
else
  require "quantum.alpha"
  require "quantum.integrations"
  require "quantum.languages"
end






