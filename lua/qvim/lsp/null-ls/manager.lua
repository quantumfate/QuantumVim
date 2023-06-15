local M = {}

local ft_map = require("lsp.null-ls._meta").ft_bridge()
local null_ls = require("null-ls")
local fn_t = require("qvim.utils.fn_t")
local Log = require "qvim.integrations.log"

local fmt = string.format

-- TODO: https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/lua/null-ls/client.lua
-- to reload null ls after installation
-- probably retry add

---Selects the option for each null-ls method by a given `ft_builtins` by the following criteria:
---
---- 1. User provided options
---- 2. Common sources between different methods (if there is a source listed in multiple methods of a filetype that source will likely be selected for all methods that list the source)
---- 3. The first available option of a method
---
---See the source for what is possible: https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/lua/null-ls/builtins/_meta/filetype_map.lua
---@generic T: table, K:string, V:table
---@generic U: table, K:string, V:string
---@param ft string
---@param ft_builtins T<K, V>
---@return U<K, V>
local function select_builtins(ft, ft_builtins)
    local _, provided = pcall(require, "qvim.lsp.null-ls.providers." .. ft .. ".lua", "methods")
    local selection = provided or {}

    local optimal_builtins = {}

    for method, options in pairs(ft_builtins) do
        if not selection[method] then
            for _, option in ipairs(options) do
                if not fn_t.has_any_key(optimal_builtins, option, true) then
                    optimal_builtins[#optimal_builtins + 1] = { option = {} }
                end
                table.insert(optimal_builtins[#optimal_builtins][option], tostring(method))
            end
        end
    end

    if #optimal_builtins > 0 then
        table.sort(optimal_builtins, function(a, b)
            return #a[next(a)] >= #b[next(b)]
        end)
        local optimal = optimal_builtins[1]
        for option, methods in pairs(optimal) do
            for _, method in pairs(methods) do
                selection[method] = option
            end
        end
    else
        return selection
    end

    for method, options in pairs(ft_builtins) do
        if not selection[method] then
            selection[method] = options[1]
        end
    end
    return selection
end

---comment
---@param ft string
---@param method string
---@param source string
local function register_sources_on_ft(ft, method, source)
    local _, provided = pcall(require, "qvim.lsp.null-ls.providers." .. ft .. ".lua")
    if method == "code_actions" then
        require("qvim.lsp.null-ls.code_actions").setup()
    elseif method == "formatters" then
        require("qvim.lsp.null-ls.formatters").setup()
    elseif method == "diagnostics" then
        require("qvim.lsp.null-ls.linters").setup()
    else
        Log:error(fmt("The method '%s' is not a valid null-ls method.", method))
    end
end

---Register all available null-ls builtins for a given filetype.
---@param filetype any
function M.setup(filetype, lsp_server)
    vim.validate { name = { filetype, "string" } }
    vim.validate { name = { lsp_server, "string" } }

    local null_ls_builtins = ft_map[filetype]

    local selection = select_builtins(filetype, null_ls_builtins)
    for method, source in pairs(selection) do
        register_sources_on_ft(filetype, method, source)
    end
end

return M
