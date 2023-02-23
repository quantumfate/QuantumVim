local M = {}

function M.in_headless_mode()
  return #vim.api.nvim_list_uis() == 0
end

function M.isempty(s)
  return s == nil or s == ""
end

function M.get_buf_option(opt)
  local status_ok, buf_option = pcall(vim.api.nvim_buf_get_option, 0, opt)
  if not status_ok then
    return nil
  else
    return buf_option
  end
end

return M
