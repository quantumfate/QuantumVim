-- Module wrapper for vim api 
-- to avoid annoying warnings

M = {
  g = vim.g,
  api = vim.api,
  fn = vim.fn,
  cmd = vim.cmd,
  opt = vim.opt,
  lsp = vim.lsp,
  diagnostic = vim.diagnostic
}

return M
