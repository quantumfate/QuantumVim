if not vim.tbl_contains(vim.opt.rtp:get(), os.getenv("QUANTUMVIM_DIR")) then
	vim.opt.rtp:prepend(os.getenv("QUANTUMVIM_DIR"))
end

require("qvim")
--require("qvim.keymaps"):init()

local manager = require("qvim.core.manager")
manager:load()

local Log = require("qvim.log")
Log:debug("Starting QuantumVim")
