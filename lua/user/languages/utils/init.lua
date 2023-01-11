local status_ok, alpha = pcall(require, "alpha")
if not status_ok then
  return
end

require "user.languages.utils.properties"
require "user.languages.utils.mason"
require "user.languages.utils.nvim-cmp"

