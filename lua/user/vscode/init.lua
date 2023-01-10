local status_ok, _ = pcall(require, "vscode")
if not status_ok then
  return
end

require "user.vscode.options"

