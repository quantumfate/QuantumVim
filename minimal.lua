local utils = require("qvim.utils.util")
utils:set_use_xpcall(true)
require("qvim.packer")
--require "qvim.impatient"
require("qvim.keymap")
require("qvim.options")
if vim.g.vscode then
	-- VSCode extension
	require("qvim.vscode")
else
	require("qvim.alpha")
	require("qvim.integrations")
	require("qvim.languages")
end
