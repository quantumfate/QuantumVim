local M = {}

local _ = require('mason-core.functional')
local null_ls_client = require("null-ls").client
local null_ls_utils = require("qvim.lsp.null-ls.util")

local fn_t = require("qvim.utils.fn_t")
local Log = require "qvim.integrations.log"

local fmt = string.format


---Takes a map of null-ls methods mapped to a table of sources and transforms supported
---sources into a functional mason package.
---
---@generic T: table, K:string, V:table<string>, M:Package|string
---@param null_ls_builtins T<K,V>
---@return T<K,T<M>>
local function get_mason_packages_or_null_ls_sources(null_ls_builtins)
    local null_ls_methods = require("qvim.lsp.null-ls._meta").method_bridge()
    local res = {}

    for method, sources in pairs(null_ls_builtins) do
        local collection = {}
        for _, source in pairs(sources) do
            null_ls_utils.resolve_null_ls_package_from_mason(source):if_present(function(package)
                table.insert(collection, package)
            end):or_else_get(function()
                table.insert(collection, source)
            end)
        end
        res[null_ls_methods[method]] = collection
    end

    return res
end

---Mason packages won't be rosolved in this function except packages that where defined by the user. So
---ideally you should already have resolved all possible mason packages for a given `ft_builtins` if you
---want them to take preredence in the selection.
---
---Selects the option for each null-ls method for a given `ft_builtins` by the following criteria:
---
---- User provided options (its entirely the users responsibility to maintain the specified source). If the
--- source is found as a package in the mason registry that package will be used unless the user provides a
--- installation spec for the package. The plain old source will be used when both of these options fail
---- Available mason packages or custom packages(Optional)
---- Common sources between different methods (if there is a source listed in multiple methods of a filetype that source will likely be selected for all methods that list the source)
---- The first available option of a method
---
---See the source for what is possible: https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/lua/null-ls/builtins/_meta/filetype_map.lua
---@generic T: table, K:string, V:table<string>, M:Package|string
---@param ft string
---@param ft_builtins T<K,T<K,table<M>>>
---@return T<K,T<K,M>>
local function select_null_ls_sources(ft, ft_builtins)
    ---@class Package
    local Package = require "mason-core.package"
    local _ = require('mason-core.functional')
    local null_ls_methods = require("qvim.lsp.null-ls._meta").method_bridge()
    local selection = {}

    local ok_provided, provided = pcall(require, "qvim.lsp.null-ls.providers." .. ft .. ".lua")
    if ok_provided and provided.methods then
        selection = get_mason_packages_or_null_ls_sources(provided.methods)
    end

    null_ls_utils.disassociate_selection_from_input(selection, ft_builtins)

    local sources_to_methods = null_ls_utils.invert_method_to_sources_map(ft_builtins)

    local sorted_combination = null_ls_utils.package_selection_sort(sources_to_methods)

    return selection
end



---Register all available null-ls builtins for a given filetype and install their corresponding mason package.
---@param filetype any
function M.setup(filetype, lsp_server)
    vim.validate { name = { filetype, "string" } }
    vim.validate { name = { lsp_server, "string" } }

    local ft_map = require("qvim.lsp.null-ls._meta").ft_bridge()
    local null_ls_builtins = ft_map[filetype]

    local method_to_package_info = get_mason_packages_or_null_ls_sources(null_ls_builtins)
    local selection = select_null_ls_sources(filetype, method_to_package_info)


    --[[     for method, source in pairs(selection) do
        if register_sources_on_ft(method, source) then
            resolve_null_ls_package_from_mason(source):if_present(
                function(package)
                    if not package:is_installed() then
                        Log:debug(fmt("Automatically installing '%s' by the mason package '%s'.", source, package.name))
                        package:install():once(
                            'closed',
                            vim.schedule_wrap(function()
                                if registry.is_installed(package.name) then
                                    Log:info(fmt("Installed '%s' by the mason package '%s'.", source, package.name))
                                    null_ls_client.retry_add()
                                    Log:info(fmt(
                                        "Null-ls reattatched after installation of '%s' respective mason package '%s'.",
                                        source, package.name))
                                else
                                    Log:warn(fmt(
                                        "Installation of '%s' by the mason package '%s' failed. Consult mason logs.",
                                        source,
                                        package.name))
                                end
                            end)
                        )
                    end
                end
            ):or_else(filetype)
        end
    end ]]
end

return M
