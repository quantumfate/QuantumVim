local M = {}

local Log = require "qvim.integrations.log"
local _ = require "mason-core.functional"
local fmt = string.format
local null_ls = require("null-ls")

local FORMATTING = null_ls.methods.FORMATTING
local DIAGNOSTICS = null_ls.methods.DIAGNOSTICS
local CODE_ACTION = null_ls.methods.CODE_ACTION

---Checks whether a given `source` is a mason package.
---@param source table|string
function M.is_package(source)
    if type(source) == "table" and source.name then
        return tostring(source) == fmt("Package(name=%s)", source.name)
    end
    return false
end

---Returns an Optional mason package either from the mason registry or creates a new mason package with
---a provided spec.
---
---For more information to custom package hangle, see: https://github.com/williamboman/mason.nvim/blob/main/lua/mason-core/package/init.lua
---@param null_ls_source_name string
---@return Package|nil
function M.resolve_null_ls_package_from_mason(null_ls_source_name)
    -- taken from mason-null-ls and modified
    -- https://github.com/jay-babu/mason-null-ls.nvim/blob/main/lua/mason-null-ls/automatic_installation.lua

    local Optional = require('mason-core.optional')
    local source_mappings = require('mason-null-ls.mappings.source')
    local registry = require('mason-registry')

    return Optional.of_nilable(source_mappings.getPackageFromNullLs(null_ls_source_name)):map(function(package_name)
        if not registry.has_package(package_name) then
            Log:warn(fmt("The null-ls source '%s' is not supported by mason.", null_ls_source_name))
        end

        local custom_is_defined, custom_pkg = M.register_custom_mason_package(null_ls_source_name)
        if custom_is_defined then
            return custom_pkg
        end

        local ok, pkg = pcall(registry.get_package, package_name)
        if ok then
            return pkg
        end

        if not custom_is_defined then
            return nil
        end
    end)
end

---Based on a given `method` a given `source` will be registered.
---@param method string
---@param source string
---@return boolean|nil
function M.register_sources_on_ft(method, source)
    local null_ls_methods = require("qvim.lsp.null-ls._meta").method_bridge()
    local _, provided = pcall(require, "qvim.lsp.null-ls.sources." .. source)
    local source_options = provided.settings or {}

    source_options["name"] = source

    local kind = nil
    if null_ls_methods[method] == CODE_ACTION then
        kind = require("qvim.lsp.null-ls.code_actions")
    elseif null_ls_methods[method] == FORMATTING then
        kind = require("qvim.lsp.null-ls.formatters")
    elseif null_ls_methods[method] == DIAGNOSTICS then
        kind = require("qvim.lsp.null-ls.linters")
    else
        Log:error(fmt("The method '%s' is not a valid null-ls method.", method))
        return kind
    end

    -- we need to pase this as a table itself to stay compatible with the service.register_sources(configs, method)
    kind.setup({ source_options })
    return true
end

---Register a custom mason package with a spec provided by the user.
---@param null_ls_source_name string
---@return boolean
---@return Package|nil
function M.register_custom_mason_package(null_ls_source_name)
    ---@class Package
    ---@field new function
    local Package = require "mason-core.package"
    local _ok, source_package_spec = pcall(require, "qvim.lsp.null-ls.packages." .. null_ls_source_name)
    if _ok then
        Log:debug(fmt(
            "A custom mason package '%s' was instanciated from the source '%s' that will be used for installation.",
            source_package_spec.name, null_ls_source_name))
        local pkg_ok, pkg = pcall(Package.new, source_package_spec)
        if pkg_ok then
            return pkg_ok, pkg
        end
    end
    return false, nil
end

---Ensures that only methods will be processed that are not selected yet
---@generic T: table, K:string, V:table<string>, M:Package|string
---@param selection T<K, V>
---@param ft_builtins T<K,T<K,table<M>>>
function M.disassociate_selection_from_input(selection, ft_builtins)
    for method, _ in pairs(ft_builtins) do
        if selection[method] then
            ft_builtins[method] = nil
        end
    end
end

---Takes a given `ft_builtins` table and inverts it so that sources are
---mapped to a table of unique methods where they are available.
---@generic T: table, K:string, V:table<string>, M:Package|string
---@param ft_builtins T<K,T<K,table<M>>>
---@return T<M,T<K>>
function M.invert_method_to_sources_map(ft_builtins)
    local inverted = {}

    for method, sources in pairs(ft_builtins) do
        for _, source in pairs(sources) do
            if not inverted[source] then
                inverted[source] = { method }
            else
                if not _.any(function(e) return method == e end, inverted[source]) then
                    table.insert(inverted[source], method)
                end
            end
        end
    end
    return inverted
end

---Computes a score for a individual combination of a package and its methods.
---A key that's a valid mason package will have a higher
---factor for computing the score than a key that's not a valid mason package. The score
---of a key will be multiplied with the score of the table of methods where each method is treated
---equally meaning that they only alter the total score in numbers.
---@param source Package|string
---@param methods table<string>
---@param methods_to_amounts table<string, integer>
---@return number score the computed score
function M.compute_score_of_source(source, methods, methods_to_amounts)
    local scores = {
        package = 25,
        string = 3,
        method = 11,
        method_score_increase = 1.2
    }
    local score
    local methods_score = #methods * scores.method

    if _.any(function(method) return methods_to_amounts[method] == 1 end, methods) then
        -- slightly increase the score of packages that are only available
        -- for one method to avoid conflicts with trailing packages that
        -- would rank the same score otherwise
        methods_score = methods_score * scores.method_score_increase
    end

    if M.is_package(source) then
        score = scores.package * methods_score
    else
        score = scores.string * methods_score
    end
    return score
end

---Takes a given `sources_to_methods` table and computes a score for each combination of
---source and methods.
---@generic T: table, K:string, V:table<string>, M:Package|string
---@param sources_to_methods T<M,T<K>> a table that maps sources to a table of one or more methods
---@param ft_builtins T<K,T<K,table<M>>> to determine the amount of appearances from methods
---@return T<integer>
---@return T<integer, T<M, T<K>>>
function M.compute_ft_builtins_score(sources_to_methods, ft_builtins)
    local methods_to_amounts = {}
    local computed_scores = {}
    local computed_scores_to_combinations = {}

    for method, sources in pairs(ft_builtins) do
        methods_to_amounts[method] = #sources
    end

    for source, methods in pairs(sources_to_methods) do
        local score = M.compute_score_of_source(source, methods, methods_to_amounts)

        table.insert(computed_scores, score)
        computed_scores_to_combinations[score] = { [source] = methods }
    end

    return computed_scores, computed_scores_to_combinations
end

---Greatest `k` selection sort for sources.
---@generic T: table, K:string, V:table<string>, M:Package|string
---@param sources_to_methods T<M,T<K>> a table that maps sources to a table of one or more methods
---@param ft_builtins T<K,T<K,table<M>>> to determine the amount of appearances from methods
---@return T<T<M,T<K>>> sorted the sorted table where the first element is the table that wraps the best combination
function M.source_selection_sort(sources_to_methods, ft_builtins)
    local computed_scores, computed_scores_to_combinations =
        M.compute_ft_builtins_score(
            sources_to_methods,
            ft_builtins
        )

    for i = #computed_scores, 1, -1 do
        local max_num = computed_scores[i]
        local max_index = i
        for j = 1, #computed_scores, 1 do
            if computed_scores[j] > max_num then
                max_num = computed_scores[j]
                max_index = j
            end
        end
        if max_num > computed_scores[i] then
            local temp = computed_scores[i]
            computed_scores[i] = computed_scores[max_index]
            computed_scores[max_index] = temp
        end
    end

    local res = {}
    for _, score in pairs(computed_scores) do
        table.insert(res, computed_scores_to_combinations[score])
    end

    return res
end

return M
