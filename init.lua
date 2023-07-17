vim.loader.enable()

require("qvim.bootstrap"):init()

--require("qvim.keymaps"):init()

local manager = require "qvim.core.manager"
manager:load()

local Log = require "qvim.log"
Log:debug "Starting QuantumVim"
