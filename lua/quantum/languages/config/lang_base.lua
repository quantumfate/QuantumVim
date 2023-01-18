local utils = require("quantum.utils.util")
utils:set_use_xpcall(true)
utils:show_variables_in_trace(true)
local debugger = utils:require_module("quantum.utils.debugger")

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
		server_extension = fields.server_extension or false,
		hook_function = fields.hook_function or {},
		lsp_server_settings = M:lsp_set_server_settings(fields.lsp_server) or fields.lsp_server_settings or {},
	}
	setmetatable(obj, { __index = self })
	if obj.server_extension then
		assert(obj.hook_function, "A hook function is required when server_extension is set to true.")
	end
  
	return obj
end

local function strip_table_to_string(value)
  if type(value) == "string" then
		return value
	elseif type(value) == "table" and #value ~= 0 then
		return value[1]
  else
    return nil
  end
end
--- LSP Language server
function M:get_lsp_server()
  return strip_table_to_string(self.lsp_server)
end

--- Null-ls builtin formatter
function M:get_formatter()
	return strip_table_to_string(self.formatter)
end

--- Null-ls builtin diagnostics
function M:get_diagnostics()
  return strip_table_to_string(self.diagnostics)
end

--- Null-ls builtin code actions
function M:get_code_actions()
  return strip_table_to_string(self.code_actions)
end

--- DAP or any other debugger
function M:get_debugger()
  return strip_table_to_string(self.debugger)
end

function M:has_server_extension()
	return self.server_extension
end

function M:get_lsp_server_settings()
	return self.lsp_server_settings
end

function M:get_hook_callback()
	return self.hook_function
end

--- Helper function to inject specific server settings
-- into server options when they exist. The file needs
-- to have the same name as the respective lsp server name.
--
-- @field lsp_server: optionally source a specific lsp_server
--
-- @return the respective settings for a language server or false if not defined
function M:lsp_set_server_settings(lsp_server)
	lsp_server = lsp_server or self.lsp_server
  local status_ok, lsp_settings = utils:require_module("quantum.languages.lsp.settings.", true)
	if not status_ok then
		return {}
	end
  vim.notify(lsp_server)
  return lsp_settings[lsp_server]
end

--- Hook to apply extensions to the basic
-- LSP configuration. It will pull the
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
-- failes and will then return false. If your LSP Server
-- extension provides a way to integrate into lsp config
-- it must ideally return a lsp config or you can wrap
-- write you own adapter to parse to this function.
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
		return false
	end
	-- inject server opts
	local status_ok, conf = pcall(require, "quantum.languages.lang." .. self.lsp_server)
	if not status_ok then
		return
	else
		conf.server = server_opts
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
