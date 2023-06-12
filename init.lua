local base_dir = vim.env.QUANTUMVIM_DIR
    or (function()
      local init_path = debug.getinfo(1, "S").source
      return init_path:sub(2):match("(.*[/\\])"):sub(1, -2)
    end)()

if not vim.tbl_contains(vim.opt.rtp:get(), base_dir) then
  vim.opt.rtp:append(base_dir)
end

require("qvim.bootstrap"):init()
require("qvim.keymaps"):init()


local integration_loader = require("qvim.integrations.loader")

integration_loader:load()

require("qvim.lsp").setup()

local Log = require "qvim.integrations.log"
Log:debug "Starting QuantumVim"
