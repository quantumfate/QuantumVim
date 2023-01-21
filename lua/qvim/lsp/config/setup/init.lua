local utils = require("qvim.utils.util")
local reqdir = utils:require_module("qvim.utils.require_dir")

local M = reqdir:require_directory_files("qvim.languages.config.setup", true)

return M
