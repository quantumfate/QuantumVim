local status_ok, _ = pcall(require, "languages")
if not status_ok then
  return
end

require "user.languages.utils"
require "user.languages.dap"
require "user.languages.lsp"
require "user.languages.lang"

