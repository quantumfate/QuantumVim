vim.loader.enable()

require("qvim.bootstrap"):init()

require("qvim.bootstrap"):setup()

local log = require("qvim.log")
log:debug("Starting QuantumVim")
