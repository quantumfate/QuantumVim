local status_ok, reqdir = pcall(require, "user.languages.utils.require_dir")
if not status_ok then
  return
end

local M = reqdir:require_directory_files("user.languages.lsp.settings", true)

return M
