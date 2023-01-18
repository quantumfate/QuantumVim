local M = {}

if vim.fn.has "nvim-0.8" ~= 1 then
  vim.notify("Please upgrade your Neovim base installation. This configuration requires v0.8+", vim.log.levels.WARN)
  vim.wait(5000, function()
    ---@diagnostic disable-next-line: redundant-return-value
    return false
  end)
  vim.cmd "cquit"
end

-- Path based on os
local uv = vim.loop
local path_sep = uv.os_uname().version:match "Windows" and "\\" or "/"



