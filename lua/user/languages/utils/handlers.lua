properties = require("user.languages.utils.properties")

--- This module initialises the necessary configuration for the developer
-- to interact with the from LSP and CMP provided functionality. 
--
-- @field M.setup() method creates initialises the style and other configurations
--        for diagnostics used for global configuration across the IDE
-- @field M.on_attach() configures key mappings and other visual utility for the
--        developer to interact with the IDE
-- @field M.capabilities() is a callback function that provides capability configuration
--        for the respective language
--
local M = {}

--- Module setup function. This function should be called before
-- any buffer is attached or any server will be Initialised.
M.setup = function()
  local signs = {
    { name = "DiagnosticSignError", text = "" },
    { name = "DiagnosticSignWarn", text = "" },
    { name = "DiagnosticSignHint", text = "" },
    { name = "DiagnosticSignInfo", text = "" },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
  end

  local config = {
    -- disable virtual text
    virtual_text = false,
    -- show signs
    signs = {
      active = signs,
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }

  vim.diagnostic.config(config)

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
  })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
  })
end

local function lsp_highlight_document(client)
  -- Set autocommands conditional on server_capabilities
  if client.server_capabilities.document_highlight then
    vim.api.nvim_exec(
      [[
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]] ,
      false
    )
  end
end

local function lsp_keymaps(bufnr)
  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>f", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "[d", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>', opts)
  vim.api.nvim_buf_set_keymap(
    bufnr,
    "n",
    "gl",
    '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics({ border = "rounded" })<CR>',
    opts
  )
  vim.api.nvim_buf_set_keymap(bufnr, "n", "]d", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition)
  vim.cmd([[ command! Format execute 'lua vim.lsp.buf.format()' ]])
end


--- This function makes sure that the internal formatting capability
-- for the respective server that calls this callback is disabled.
-- Addionally key mappings and other autocommands will be attached 
-- to the current buffer.
--
-- @field client will be parsed by the lua api on the respective server
-- @field the buffer of the respective server
M.on_attach = function(client, bufnr)
  client.server_capabilities.document_formatting = false

  lsp_keymaps(bufnr)
  lsp_highlight_document(client)
end

--- This function is a callback functions that returns capabilities for the 
-- respective server it will be called on.
--
-- @return modified capabilities to integrate a server into cmp
M.capabilities = function()
  local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if not status_ok then
    return
  end

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  
  -- Initialise cmp specific capabilities to be hooked into CMP
  return cmp_nvim_lsp.default_capabilities(capabilities)
end


--- Helper function to inject specific server settings
-- into server options when they exist. The file needs
-- to have the same name as the respective lsp server name.
--
-- @field lsp server
-- @field server_opts the basic server options
--
-- @return the updated map when settings exist otherwise returns the basic server 
--         options field without modifications
local function apply_server_specific_settings(lsp, server_opts)
  local lsp_settings_status_ok, lsp_opts = pcall(require, "user.languages.lsp.settings." .. lsp)
  if lsp_settings_status_ok then
    return vim.tbl_deep_extend("force", lsp_opts, server_opts)
  else 
    return server_opts
  end
end

--- Initialises lsp server configuration for supported 
-- lsp servers by mason. If a server is defined in properties.maintained
-- this method will call a dynamic hook based on the lsp server in
-- question. Addionally this function uses an helper function
-- to inject settings if they exist no server if found it will print and error message.
-- @field lspconfig - a required lspconfig that setup can be called on
-- @field server_opts - options that should be parsed to an lsp server
--
-- @return the updated lsp configuration
M.init_lsp_server_config = function(lspconfig, server_opts)
  local supported_lsp_servers = properties.servers
  local self_maintained_lsp_servers = properties.maintained
  local supported_set = {}
  local maintained_set = {}

  for i, value in ipairs(supported_lsp_servers) do
    supported_set[value] = true
  end

  for i, value in ipairs(self_maintained_lsp_servers) do
    maintained_set[value] = true
  end

  for _, lsp in ipairs(supported_lsp_servers) do

    local opts = server_opts
    if maintained_set[lsp] or supported_set[lsp] then
      opts = apply_server_specific_settings(lsp, server_opts)
    end

    if maintained_set[lsp] then
      -- Server in question adds something to LSP
      local hook = maintained_hooks[lsp]
      return lspconfig[lsp] = hook.hook_server_config(opts)
    elseif supported_set[lsp] then
      -- Basic LSP setup
      return lspconfig[lsp].setup(opts)
    end
    -- error something went wrong
    print("The Server " .. lsp .. " is not supprted nor maintained.")
  end
end

return M
