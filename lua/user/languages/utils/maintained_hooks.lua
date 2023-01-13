--- This module defines a set of hooks that can 
-- be dynamically called based on lsp server names.
-- For example if you want to define special needs
-- and configurations that are completely out of scope
-- for the simple lspconfig setup this module will
-- allow you to dynamically hook data.
--
-- @field M.clangd - clangd_extensions 
local M = {}

--- A clangd endpoint to inject additional functionality
--- into a simplified setup
M.clangd = {
  --- Clangd Hook to apply extensions to the basic
  -- LSP clang configuration. It calls the prepare
  -- function of the clangd_extensions module
  -- to return a lsp-config table that will then be used
  -- to attach the server settings.
  hook_server_config = function(server_opts) 
    return require("clangd_extensions").prepare(function(server_opts) 
      return require("user.languages.lang.clangd").server = server_opts
    end)
  end
}

return M
