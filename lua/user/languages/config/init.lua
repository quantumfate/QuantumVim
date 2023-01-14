local M = {}

-- Init
function M:new()
  local obj = {
    c = require("user.languages.lsp.conf.c"),
    cpp = require("user.languages.lsp.conf.cpp"),
    lua = require("user.languages.lsp.conf.lua"),
    python = require("user.languages.lsp.conf.python"),
    ansible = require("user.languages.lsp.conf.ansible"),
  }
  setmetatable(obj, { __index = self })
end


function M:get_unique_lsp_server_list()
  return self:get_unique_attr_list("lsp_server")
end

function M:get_unique_formatter_list()
  return self:get_unique_attr_list("formatter")
end

function M:get_unique_diagnostics_list()
  return self:get_unique_attr_list("diagnostics")
end

function M:get_unique_debugger_list()
  return self:get_unique_attr_list("debugger")
end

function M:get_unique_code_actions_list()
  return self:get_unique_attr_list("code_actions")
end

--- This function uses the get_configured_languages() function to get a 
-- list of languages, then iterates through that list to get 
-- the corresponding language server for each language. 
-- It uses a attr_flag table to keep track of which servers 
-- have already been added to the attr_set table, 
-- and only adds a server to the attr_set table if 
-- it has not been added yet. Finally, it returns the 
-- @return table containing the unique list of servers.
function M:get_unique_attr_list(attr)
  
  local language_attr = {}
  local attr_flag = {}

  for configured_language, language_fields in pairs(self) do
      
    -- Go to the next iteration when attr is empty
    if language_fields[attr] == nil or #language_fields[attr] == 0 then
      break
      vim.notify("No attribute with the name '" .. attr .. "' configured in the language '" .. configured_language .. "'.", "info")
    end

  -- Get attributes from current language
    if type(language_fields[attr]) == "table" then
      -- configured as table
      for i, member in pairs(language_fields[attr]) do
      -- Iterate list of attributes in current fields
        if type(member) == "string" then
          language_attr[#language_attr + 1] = language_fields[attr][i]
          attr_flag[language_fields[attr][i]] = true
        end
      end
      break
    elseif type(language_fields[attr]) == "string" then
      -- If the value is configured as a string
      language_attr[#language_attr + 1] = language_fields[attr]
      -- Create a flag list to track each server state
      attr_flag[language_fields[attr]] = true
    end
  end

  -- Return empty table when not attributes are configured
  if #language_attr == 0 then
    vim.notify("No attributes for any language were configured", "warning")
    return {}
  end

  local attr_set = {}
  -- Add attribute to list when not added yet
  for i, attr in pairs(language_attr) do
    if attr_flag[attr] then
      attr_set[i] = attr
      attr_flag[attr] = false
    end
  end

  return attr_set
end

return M
