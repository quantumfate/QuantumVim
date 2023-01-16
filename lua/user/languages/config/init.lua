local M = {}

local util_ok, my_util = pcall(require, "user.languages.utils.util")
if not util_ok then
  return
end

--- The new() function is a constructor for creating a new object that contains 
-- the specified languages. The languages parameter is optional, 
-- if it is not passed, the function will try to require 
-- the "user.languages.config.setup" module, which should contain the languages.
-- The function also requires the "user.languages.config.lang_base" module, 
-- which is used as a base for the languages.
-- The function creates an empty table called obj and then 
-- iterates over the languages table, adding the language 
-- name as a key and a new object created with the lang_base and the 
-- language table as the value. The function then sets the metatable 
-- of the obj table to be the current object, so that 
-- it inherits any methods or properties from the current object.
--
-- @field language: optional parameter to define which lsp servers
--                  should be installed
--
-- @return the obj table, which contains the languages. 
--         If something goes wrong, the function will return false.
function M:new(languages)

  local languages = languages or require("user.languages.config.setup")
  
  require"user.languages.config.lang_base"
  local m_status_ok, lang_base = pcall(require, "user.languages.config.lang_base")
  if not m_status_ok then 
    vim.notify("Something went wrong when requiring the lang_base for languages.", "warning")
    return
  else

    obj = {}
    for language, table in pairs(languages) do
      obj[language] = lang_base:new(table)
    end

    setmetatable(obj, { __index = self })
    return obj
  end
  return false
end


--- Wraps the get_unique_attr_server_list to
-- call get_unique_attr_list with lsp_server as an attribute
function M:get_unique_lsp_server_list()
  return self:get_unique_attr_list("lsp_server")
end

--- Wraps the get_unique_attr_server_list to
-- call get_unique_attr_list with formatter as an attribute
function M:get_unique_formatter_list()
  return self:get_unique_attr_list("formatter")
end

--- Wraps the get_unique_attr_server_list to
-- call get_unique_attr_list with diagnostics as an attribute
function M:get_unique_diagnostics_list()
  return self:get_unique_attr_list("diagnostics")
end

--- Wraps the get_unique_attr_server_list to
-- call get_unique_attr_list with debugger as an attribute
function M:get_unique_debugger_list()
  return self:get_unique_attr_list("debugger")
end

--- Wraps the get_unique_attr_server_list to
-- call get_unique_attr_list with code_actions as an attribute
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
     vim.notify("No attribute with the name '" .. attr .. "' configured in the language '" .. configured_language .. "'.", "info")
     break
    end
  
    -- Get attributes from current langjuage
   if type(language_fields[attr]) == "table" then
   -- configured as table
     for i, member in pairs(language_fields[attr]) do
     -- Iterate list of attributes in current fields
       if type(member) == "string" then
         language_attr[#language_attr + 1] = language_fields[attr][i]
         attr_flag[language_fields[attr][i]] = true
       end
     end
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

  local attr_set = {} -- Add attribute to list when not added yet
  for i, attr in ipairs(language_attr) do
    if attr_flag[attr] then
      attr_set[i] = attr
      attr_flag[attr] = false
    end
  end

  return attr_set
end

return M
