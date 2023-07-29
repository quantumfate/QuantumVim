vim.loader.enable()

require("qvim.bootstrap"):init()

require("qvim.bootstrap"):setup()
--require("qvim.keymaps"):init()

local log = require("qvim.log")
log:debug("Starting QuantumVim")
