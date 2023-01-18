local utils = require("quantum.utils.util")

local null_ls = utils:require_module("null-ls")
local mason_null_ls = utils:require_module("mason-null-ls")
local lsp_config = utils:require_cached_module("quantum.languages.lsp.lspconfig")

local configured_language_diagnostics = lsp_config.configured_languages:get_unique_diagnostic_list()
local configured_language_formatters = lsp_config.configured_languages:get_unique_formatter_list()
local mason_available_sources = mason_null_ls:get_available_sources()
local ensure_installed = {unpack(configured_language_diagnostics), unpack(configured_language_formatters)}
-- TODO apply proper diagnostics and formatting engines
-- null_ls.setup(
--     sources = {
--         -- all sources go here.
--     }
-- )
mason_null_ls.setup({
    ensure_installed = ensure_installed,
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
    diagnostics.selene,
  },
})
require 'mason-null-ls'.setup_handlers() -- If `automatic_setup` is true.
