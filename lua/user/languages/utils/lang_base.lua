
--- Creates a base table for attributes a language configuration
-- can implement. A language configuration can implement more then
-- the provided fields from the lang_base module but this module
-- is supposed to be a unified hook across all supported languages.
--
-- any of the following will be  mapped to the
-- respective mason configuration.
--
-- Additionally his module defines a set of hooks that can 
-- be dynamically called based on lsp server names.
-- For example if you want to define special needs
-- and configurations that are completely out of scope
-- for the simple lspconfig setup this module will
-- allow you to dynamically hook data.
--
-- @field M.hook_server_extension_config_with_function - A generic
--        hook for language servers that allows you to inject
--        a function specific for the server. Injects server settings

local M = {}

function M:new(fields)
  fields = fields or {}
  
  local obj = {
    lsp_server = fields.lsp_server or "",
    formatter = fields.formatter or {},
    diagnostics = fields.diagnostics or {},
    code_actions = fields.code_actions or {},
    debugger = fields.debugger or {},
    has_server_extension = fields.has_server_extension or false,
    hook_function = fields.hook_function or {},
    lsp_server_settings = fields.lsp_server_settings or M:lsp_server_settings()
  }
  setmetatable(obj, { __index = self })
  if obj.fields.has_server_extension then
    assert(obj.fields.hook_function, "A hook function is required when has_server_extension is set to true.")
  end
  return obj
end

--- LSP Language server
function M.get_lsp_server()
  return self.lsp_server 
end


--- Null-ls builtin formatter
function M:get_formatter()
  return self.formatter
end

--- Null-ls builtin diagnostics
function M:get_diagnostics()
  return self.diagnostics
end

--- Null-ls builtin code actions
function M:get_code_actions()
  return self.code_actions
end

--- DAP or any other debugger
function M:get_debugger()
  return self.debugger
end

function M:has_server_extension()
  return self.has_server_extension
end

--- The hook function a specific language can 
-- implement to be injected into a hook
function M:hook_function() 
  return self.hook_function
end
--- This can be used to inject server specific 
-- settings to lsp. It will also be used to parse LSP Settings
-- from json to lua and read vice verca to provide a centralised
-- configuration option for each specific language server.
--
-- @return the respective settings for a language server or false if not defined
function M:get_lsp_server_settings()
  local status_ok, lsp_settings = pcall(require, "user.languages.lsp.settings." .. self.lsp_server)
  if not status_ok then
    return lsp_settings
  end
  return {}
end

--- Hook to apply extensions to the basic
-- LSP clang configuration. It will pull the
-- special configuration for the respective language.
-- This specific function allows you to parse a method
-- to integrate the configuration into LSP Config when
-- your language server extension provides that. The
-- configuration will then be injected to that method.
-- The result of the function you inject will be returned meaning 
-- that what ever will be returned by the injected function this function
-- will return too. This function will return false when 
-- the configuration could not be required. This method will
-- give an error when the injected function call 
-- failes and will then return false
--
-- @field language_server the language the configuration should be required from 
-- @field server_opts the server options that should be injected
-- @field specific_function the function this hook should call with server_opts
--
-- @return false if injected function call fails or the specific language_server
--         settings could not be required otherwise returns what
--         you injected function returns as a result
function M:hook_server_extension_config_with_function(server_opts) 
  if self.lsp_server == "" then
    vim.notify("No server specified when hooking server extension", "error")
    return false, {}
  end
  -- inject server opts
  local status_ok, conf =  require("user.languages.lang." .. self.lsp_server).server = server_opts
  if not status_ok then
    return
  end
  -- The injected function call
  local success, result = pcall(self.hook_function, conf)
  if success then
    return result
  else
    vim.notify("The specific function for your server failed", "error")
  end
  
end

return M
