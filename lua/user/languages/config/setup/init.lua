local utils = require("user.utils.util")
local reqdir = utils:require_module("user.utils.require_dir")

local M = reqdir:require_directory_files("user.languages.config.setup", true)

return M
