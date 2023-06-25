local M = {}

local Log = require "qvim.integrations.log"
local utils = require "qvim.utils"
local lang_utils = require "qvim.lang.utils"

local ftplugin_dir = qvim.lsp.templates_dir
local fmt = string.format

local join_paths = _G.join_paths

function M.remove_template_files()
  -- remove any outdated files
  for _, file in ipairs(vim.fn.glob(ftplugin_dir .. "/*.lua", 1, 1)) do
    vim.fn.delete(file)
  end
end

local skipped_filetypes = qvim.lsp.automatic_configuration.skipped_filetypes
local skipped_servers = qvim.lsp.automatic_configuration.skipped_servers
local ensure_installed_servers = qvim.lsp.installer.setup.ensure_installed

---Check if we should skip generating an ftplugin file based on the server_name
---@param server_name string name of a valid language server
local function should_skip(server_name)
  -- ensure_installed_servers should take priority over skipped_servers
  return vim.tbl_contains(skipped_servers, server_name) and not vim.tbl_contains(ensure_installed_servers, server_name)
end

---Generates an ftplugin with a selected language server.
---@param filetype string the filetype
---@param server_name string name of a valid language server, e.g. pyright, gopls, tsserver, etc.
---@param dir string the full path to the desired directory
function M.generate_ftplugin(filetype, server_name, dir)
  if should_skip(server_name) then
    return
  end

  filetype = filetype:match "%.([^.]*)$" or filetype
  local filename = join_paths(dir, filetype .. ".lua")
  local setup_server_cmd = string.format([[require("qvim.lang.lsp.manager").setup(%q,%q)]], server_name, filetype)
  local setup_null_ls_cmd = string.format([[require("qvim.lang.null-ls.manager").setup(%q,%q)]], filetype, server_name)
  utils.write_file(filename, setup_server_cmd .. "\n" .. setup_null_ls_cmd .. "\n", "a")
end

---Generates ftplugin files based on a map where filetypes are mapped to language servers
---The files are generated to a runtimepath: "$QUANTUMVIM_DIR/site/after/ftplugin/template.lua"
---@param filetype_server_map? table<string, table<string>> list of servers to be enabled. Will add all by default
function M.generate_templates(filetype_server_map)
  filetype_server_map = filetype_server_map or lang_utils.get_all_supported_filetypes_to_servers()
  print("servers", vim.inspect(filetype_server_map))
  Log:debug "Templates installation in progress"

  M.remove_template_files()

  -- create the directory if it didn't exist
  if not utils.is_directory(qvim.lsp.templates_dir) then
    vim.fn.mkdir(ftplugin_dir, "p")
  end

  for ft, servers in pairs(filetype_server_map) do
    if not vim.tbl_contains(skipped_filetypes, ft) then
      local selected_server = lang_utils.select_language_server(ft, servers)
      M.generate_ftplugin(ft, selected_server, ftplugin_dir)
    else
      Log:debug(fmt("Skipped filetype generation for filetype '%s'.", ft))
    end
  end
  Log:debug "Templates installation is complete"
end

return M
