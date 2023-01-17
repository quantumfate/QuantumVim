local status_ok, reqdir = pcall(require, "user.languages.utils.require_dir")
if not status_ok then
  return
end

--reqdir = require("user.languages.utils.require_dir")

local M = reqdir:require_directory_files("user.languages.config.setup", true)

return M
