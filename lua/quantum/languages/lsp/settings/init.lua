local utils = require("quantum.utils.util")
local reqdir = utils:require_module("quantum.utils.require_dir")

local debugger = utils:require_module("quantum.utils.debugger")
local M = reqdir:require_directory_files("quantum.languages.lsp.settings", true)

return M
