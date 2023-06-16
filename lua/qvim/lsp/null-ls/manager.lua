local M = {}
local _ = require('mason-core.functional')
local registry = require('mason-registry')
---@class EventEmitter
local EventEmitter = require "mason-core.EventEmitter"
---@class Package
---@field new function
local Package = require "mason-core.package"
local null_ls_client = require("null-ls").client
local fn_t = require("qvim.utils.fn_t")
local Log = require "qvim.integrations.log"

local fmt = string.format

-- TODO: https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/lua/null-ls/client.lua
-- to reload null ls after installation
-- probably retry add

---Selects the option for each null-ls method for a given `ft_builtins` by the following criteria:
---
---- User provided options (its entirely the users responsibility to maintain the specified source)
---- Available mason packages or custom packages
---- Common sources between different methods (if there is a source listed in multiple methods of a filetype that source will likely be selected for all methods that list the source)
---- The first available option of a method
---
---See the source for what is possible: https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/lua/null-ls/builtins/_meta/filetype_map.lua
---@generic T: table, K:string, V:table
---@generic U: table, K:string, V:string
---@param ft string
---@param ft_builtins T<K, V>
---@return U<K, V>
local function select_null_ls_sources(ft, ft_builtins)
    local _, provided = pcall(require, "qvim.lsp.null-ls.providers." .. ft .. ".lua")
    local selection = provided.methods or {}
    -- TODO: favor sources that are supported by mason
    local optimal_builtins = {}

    for method, options in pairs(ft_builtins) do
        if not selection[method] then
            for _, option in ipairs(options) do
                if not fn_t.has_any_key(optimal_builtins, option, true) then
                    optimal_builtins[#optimal_builtins + 1] = { option = {} }
                else
                    table.insert(optimal_builtins[#optimal_builtins][option], tostring(method))
                end
            end
        end
    end

    if #optimal_builtins > 0 then
        table.sort(optimal_builtins, function(a, b)
            return #a[next(a)] > #b[next(b)]
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

---Based on a given `method` a given `source` will be registered.
---@param method string
---@param source string
---@return boolean
local function register_sources_on_ft(method, source)
    local _, provided = pcall(require, "qvim.lsp.null-ls.sources." .. source)
    local source_options = provided.settings or {}

    source_options["name"] = source

    local kind = nil
    if method == "code_actions" then
        kind = require("qvim.lsp.null-ls.code_actions")
    elseif method == "formatting" then
        kind = require("qvim.lsp.null-ls.formatters")
    elseif method == "diagnostics" then
        kind = require("qvim.lsp.null-ls.linters")
    else
        Log:error(fmt("The method '%s' is not a valid null-ls method.", method))
        return kind
    end

    -- we need to pase this as a table itself to stay compatible with the service.register_sources(configs, method)
    kind.setup({ source_options })
    return true
end

---Returns an Optional mason package either from the mason registry or creates a new mason package with
---a provided spec.
---
---For more information to custom package hangle, see: https://github.com/williamboman/mason.nvim/blob/main/lua/mason-core/package/init.lua
---@param null_ls_source_name string
---@return Package|nil
local function resolve_null_ls_package_from_mason(null_ls_source_name)
    -- taken from mason-null-ls and modified
    -- https://github.com/jay-babu/mason-null-ls.nvim/blob/main/lua/mason-null-ls/automatic_installation.lua

    local Optional = require('mason-core.optional')
    local source_mappings = require('mason-null-ls.mappings.source')

    return Optional.of_nilable(source_mappings.getPackageFromNullLs(null_ls_source_name)):map(function(package_name)
        if not registry.has_package(package_name) then
            Log:warn(fmt("The null-ls source '%s' is not supported by mason.", null_ls_source_name))
            local _ok, source_package_spec = pcall(require, "qvim.lsp.null-ls.packages." .. "null_ls_source_name")
            if _ok then
                Log:debug(fmt("A custom mason package '%s' was instanciated from the source '%s'.",
                    source_package_spec.name, null_ls_source_name))
                return Package.new(source_package_spec)
            end
            return nil
        end
        local ok, pkg = pcall(registry.get_package, package_name)
        if ok then
            return pkg
        end
    end)
end

---Takes a map of null-ls methods mapped to supported sources and returns a map where individual
---sources are mapped to one and only one of the following:
---
---- a functional mason package that can be used to start the installation
---- a boolean(false) if the source is not a mason package
---by a functional Package instance.
---@generic T: table, K:string, V:table<string>, M:Package|string
---@param null_ls_builtins T<K,V>
---@return T<K,T<K,M>>
local function get_mason_packages_or_null_ls_sources(null_ls_builtins)
    local table = {}

    for method, sources in pairs(null_ls_builtins) do
        local collection = {}
        for _, source in pairs(sources) do
            resolve_null_ls_package_from_mason(source):if_present(function(package)
                collection[source] = package
            end):or_else_get(function()
                collection[source] = false
            end)
        end
        table[method] = collection
    end

    return table
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
