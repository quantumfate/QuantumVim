local base_dir = vim.env.QUANTUMVIM_DIR
    or (function()
      local init_path = debug.getinfo(1, "S").source
      return init_path:sub(2):match("(.*[/\\])"):sub(1, -2)
    end)()

if not vim.tbl_contains(vim.opt.rtp:get(), base_dir) then
  vim.opt.rtp:prepend(base_dir)
end

print(vim.env.QUANTUMVIM_DIR)

require("qvim.bootstrap"):init()
require("qvim.keymaps"):init()


local integration_loader = require("qvim.integrations.loader")

integration_loader:load()

local Log = require "qvim.integrations.log"
Log:debug "Starting QuantumVim"
