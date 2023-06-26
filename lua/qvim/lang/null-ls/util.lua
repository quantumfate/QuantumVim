local M = {}

local Log = require("qvim.integrations.log")
local _ = require("mason-core.functional")
local fmt = string.format
local null_ls = require("null-ls")
local shared_util = require("qvim.lang.utils")

local FORMATTING = null_ls.methods.FORMATTING
local DIAGNOSTICS = null_ls.methods.DIAGNOSTICS
local CODE_ACTION = null_ls.methods.CODE_ACTION


---Returns an Optional mason package either from the mason registry or creates a new mason package with
---a provided spec.
---
---For more information to custom package hangle, see: https://github.com/williamboman/mason.nvim/blob/main/lua/mason-core/package/init.lua
---@param null_ls_source_name string
---@return Package|nil
function M.resolve_null_ls_package_from_mason(null_ls_source_name)
	-- taken from mason-null-ls and modified
	-- https://github.com/jay-babu/mason-null-ls.nvim/blob/main/lua/mason-null-ls/automatic_installation.lua

	local Optional = require("mason-core.optional")
	local source_mappings = require("mason-null-ls.mappings.source")
	local registry = require("mason-registry")

	return Optional.of_nilable(source_mappings.getPackageFromNullLs(null_ls_source_name)):map(function(package_name)
		if not registry.has_package(package_name) then
			Log:warn(fmt("The null-ls source '%s' is not supported by mason.", null_ls_source_name))
		end


		local custom_is_defined, custom_pkg = shared_util.register_custom_mason_package(null_ls_source_name,
			"qvim.lang.null-ls.packages")
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
---@param source string|Package
---@return boolean|nil
function M.register_sources_on_ft(method, source)
	local null_ls_methods = require("qvim.lang.null-ls._meta").method_bridge()
	local mason_null_ls_mapping = require("mason-null-ls.mappings.source")
	local source_options = {}
	if not shared_util.is_package(source) then
		local _, provided = pcall(require, "qvim.lang.null-ls.sources." .. source)
		source_options = provided.settings or {}
	else
		source = mason_null_ls_mapping.getNullLsFromPackage(source.name)
	end

	source_options["name"] = source

	local kind = nil
	if null_ls_methods[method] == CODE_ACTION then
		kind = require("qvim.lang.null-ls.code_actions")
	elseif null_ls_methods[method] == FORMATTING then
		kind = require("qvim.lang.null-ls.formatters")
	elseif null_ls_methods[method] == DIAGNOSTICS then
		kind = require("qvim.lang.null-ls.linters")
	else
		Log:error(fmt("The method '%s' is not a valid null-ls method.", method))
		return kind
	end

	-- we need to pase this as a table itself to stay compatible with the service.register_sources(configs, method)
	kind.setup({ source_options })
	Log:info(fmt("Source '%s' for method '%s' was registered.", source, method))
	return true
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
---mapped to a set view of unique methods where they are available.
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
				if not _.any(function(e)
						return method == e
					end, inverted[source]) then
					table.insert(inverted[source], method)
				end
			end
		end
	end
	return inverted
end

---Computes a score for a source of a method. Valid mason packages rank higher than non mason
---packages. The base score of the `source` will be multiplied with the `source_amount`. The `priority`
---is added to the overall score.
---@param source Package|string valid mason package or just a string
---@param source_amount number the amount of appearances of a source across all methods
---@param priority number the first `source` has a higher priority than the last
---@return number score the computed score
function M.compute_score_of_source(source, source_amount, priority)
	local scores = { package = 10, string = 2 }
	local score = shared_util.is_package(source) and scores.package or scores.string
	return score * source_amount + priority
end

---Takes a given `ft_builtins` table and computes a score for each source of a method table.
---@generic T: table, K:string, V:table<string>, M:Package|string
---@param ft_builtins T<K,T<K,table<M>>> to determine the amount of appearances from methods
---@return T<string, T<number>>, T<string, T<number, M>>
function M.compute_ft_builtins_score(ft_builtins)
	local sources_to_amounts = {} ---@type table<string|Package, number>
	local method_to_scores = {}
	local method_to_score_to_source = {}

	for _, sources in pairs(ft_builtins) do
		for _, source in pairs(sources) do
			if not sources_to_amounts[source] then
				sources_to_amounts[source] = 1
			else
				sources_to_amounts[source] = sources_to_amounts[source] + 1
			end
		end
	end

	for method, sources in pairs(ft_builtins) do
		local score
		local computed_scores = {}
		local score_to_source = {}
		local source_count = #sources
		for _, source in pairs(sources) do
			local source_amount = sources_to_amounts[source] ---@type number
			score = M.compute_score_of_source(source, source_amount, source_count)
			table.insert(computed_scores, score)
			score_to_source[score] = source
			source_count = source_count - 1
		end
		method_to_scores[method] = computed_scores
		method_to_score_to_source[method] = score_to_source
	end

	return method_to_scores, method_to_score_to_source
end

---Selection sort that sorts a given list of `computed_scores` from highest to lowest.
---@param computed_scores table<number>
local function selection_sort(computed_scores)
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
end

---Greatest `k` selection sort for sources.
---@generic T: table, K:string, V:table<string>, M:Package|string
---@param ft_builtins T<K,T<K,table<M>>> to determine the amount of appearances from methods
---@return T<K, T<M>>
function M.source_selection_sort(ft_builtins)
	local sorted_ft_builtins = {}

	local method_to_scores, method_to_score_to_source = M.compute_ft_builtins_score(ft_builtins)

	for method, scores in pairs(method_to_scores) do
		selection_sort(scores)
		print("Scores:", method, vim.inspect(scores))
	end

	for method, sorted_scores in pairs(method_to_scores) do
		local sorted_sources = {}
		for _, score in pairs(sorted_scores) do
			table.insert(sorted_sources, method_to_score_to_source[method][score])
		end
		sorted_ft_builtins[method] = sorted_sources
	end

	return sorted_ft_builtins
end

return M
