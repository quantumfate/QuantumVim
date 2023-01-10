
local status_ok, _ = pcall(require, "lang")
if not status_ok then
	return
end

require "clangd_extensions"
require "rust-tools"
