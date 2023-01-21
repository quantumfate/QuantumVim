jlocal base_dir = vim.env.QUANTUMVIM_BASE_DIR
  or (function()
    local init_path = debug.getinfo(1, "S").source
    return init_path:sub(2):match("(.*[/\\])"):sub(1, -2)
  end)()

if not vim.tbl_contains(vim.opt.rtp:get(), base_dir) then
  vim.opt.rtp:append(base_dir)
end

require("qvim.bootstrap"):init(base_dir)

require("qvim.config"):load()

local plugins = require "qvim.plugins"

require("qvim.plugin-loader").load { plugins, qvim.plugins }

require("qvim.core.theme").setup()

local Log = require "qvim.utils.log"
Log:debug "Starting LunarVim"

local commands = require "qvim.core.commands"
commands.load(commands.defaults)

require("qvim.lsp").setup()