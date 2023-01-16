local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  return
end

local mason_null_ls_status_ok, mason_null_ls = pcall(require, "mason-null-ls")
if not mason_null_ls_status_ok then
  return
end


-- TODO apply proper diagnostics and formatting engines
-- null_ls.setup(
--     sources = {
--         -- all sources go here.
--     }
-- )
mason_null_ls.setup({
    ensure_installed = nil,
    automatic_installation = true,
    automatic_setup = true,
})
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup({
  debug = false,
  sources = {
    formatting.prettier.with({ extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" } }),
    formatting.black.with({ extra_args = { "--fast" } }),
    formatting.stylua,
    formatting.clang_format.with({ extra_args = { "--style=GNU" } }),
    diagnostics.flake8,
  },
})
