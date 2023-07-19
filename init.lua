vim.loader.enable()

require("qvim.bootstrap"):init()

require("qvim.bootstrap"):setup()
--require("qvim.keymaps"):init()



local Log = require "qvim.log"
Log:debug "Starting QuantumVim"
