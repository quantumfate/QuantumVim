local utils = require("qvim.utils.util")
local notify = utils:require_module("notify")

notify.setup({
  icons = {
    DEBUG = "",
    ERROR = "",
    INFO = "",
    TRACE = "",
    WARN = "",
    OFF = "",
  } 
})

vim.notify = notify
