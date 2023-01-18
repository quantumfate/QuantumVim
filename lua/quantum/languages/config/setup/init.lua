local utils = require("quantum.utils.util")
local reqdir = utils:require_module("quantum.utils.require_dir")

local M = reqdir:require_directory_files("quantum.languages.config.setup", true)

return M
