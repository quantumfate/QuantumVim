---A module for registering null-ls sources and listing registered sources
---@class MethodService
---@field method string
---@field method_str_arg string
---@field log NoneLsLog
local MethodService = {}
MethodService.__index = MethodService
MethodService.log = require("qvim.log").none_ls
MethodService.fn_t = require("qvim.utils.fn_t")

local fmt = string.format

---Create a new MethodService
---@generic T
---@param method string
---@return T<MethodService>
function MethodService:init(method)
	local instance = {}
	instance.method = method
	instance.method_str_arg =
		require("qvim.lang.null-ls._meta").method_to_string_arg()[method]
	setmetatable(instance, MethodService)
	return instance
end

---Find the root directory of the current project
---@return unknown
local function find_root_dir()
	local util = require("lspconfig.util")
	local lsp_utils = require("qvim.lang.lsp.utils")

	local ts_client = lsp_utils.is_client_active("typescript")
	if ts_client then
		return ts_client.config.root_dir
	end
	local dirname = vim.fn.expand("%:p:h")
	return util.root_pattern("package.json")(dirname)
end

---Find a command in the node_modules directory of the current project
---@param command any
---@return nil
local function from_node_modules(command)
	local root_dir = find_root_dir()

	if not root_dir then
		return nil
	end

	local join_paths = require("qvim.utils").join_paths
	return join_paths(root_dir, "node_modules", ".bin", command)
end

local local_providers = {
	prettier = { find = from_node_modules },
	prettierd = { find = from_node_modules },
	prettier_d_slim = { find = from_node_modules },
	eslint_d = { find = from_node_modules },
	eslint = { find = from_node_modules },
	stylelint = { find = from_node_modules },
}

---List registered providers for a given filetype
---@param filetype any
---@return table
function MethodService:list_registered(filetype)
	local registered_sources = require("null-ls").get_source({
		filetype = filetype,
		method = self.method,
	})
	local source_names = {}
	for _, source in ipairs(registered_sources) do
		table.insert(source_names, source.name)
	end
	return source_names
end

---Find a command in the node_modules directory of the current project
---@param command any
---@return unknown
function MethodService.find_command(command)
	if local_providers[command] then
		local local_command = local_providers[command].find(command)
		if local_command and vim.fn.executable(local_command) == 1 then
			return local_command
		end
	end

	if command and vim.fn.executable(command) == 1 then
		return command
	end
	return nil
end

---List registered providers for a given filetype
---@param filetype any
---@return table
function MethodService.list_registered_providers_names(filetype)
	local s = require("null-ls.sources")
	local available_sources = s.get_available(filetype)
	local registered = {}
	for _, source in ipairs(available_sources) do
		for method in pairs(source.methods) do
			registered[method] = registered[method] or {}
			table.insert(registered[method], source.name)
		end
	end
	return registered
end

function MethodService:list_supported(filetype)
	local s = require("null-ls.sources")
	local supported_formatters = s.get_supported(filetype, self.method_str_arg)
	table.sort(supported_formatters)
	return supported_formatters
end

---Register sources for a given table of source configurations
---@param configs any
---@return table
function MethodService:register_sources(configs)
	local null_ls = require("null-ls")
	local is_registered = require("null-ls.sources").is_registered

	local sources, registered_names = {}, {}

	for _, config in ipairs(configs) do
		local cmd = config.exe or config.command
		local name = config.name or cmd:gsub("-", "_")
		local type = self.method == null_ls.methods.CODE_ACTION
				and "code_actions"
			or null_ls.methods[self.method]:lower()
		local source = type and null_ls.builtins[type][name]
		self.log.debug(
			fmt("Received request to register [%s] as a %s source", name, type)
		)
		if not source then
			self.log.error("Not a valid source: " .. name)
		elseif
			is_registered({ name = source.name or name, method = self.method })
		then
			self.log.trace(
				fmt("Skipping registering [%s] more than once", name)
			)
		else
			local command = MethodService.find_command(source._opts.command)
				or source._opts.command

			-- treat `args` as `extra_args` for backwards compatibility. Can otherwise use `gnerator_opts.args`
			local compat_opts = vim.deepcopy(config)
			if config.args then
				compat_opts.extra_args = config.args or config.extra_args
				compat_opts.args = nil
			end

			local opts =
				vim.tbl_deep_extend("keep", { command = command }, compat_opts)
			self.log.debug("Registering source " .. name)
			table.insert(sources, source.with(opts))
			vim.list_extend(registered_names, { source.name })
		end
	end

	if #sources > 0 then
		null_ls.register({ sources = sources })
	end
	return registered_names
end

---Setup null-ls sources by a given table of source configurations. The method
---is inferred of the self.method property of the MethodService.
---@param generic_configs any
function MethodService:setup(generic_configs)
	if vim.tbl_isempty(generic_configs) then
		return
	end

	local registered = self:register_sources(generic_configs)

	if #registered > 0 then
		self.log.debug(
			"Registered the following "
				.. self.method_str_arg
				.. ": "
				.. unpack(registered)
		)
	end
end

return setmetatable({}, MethodService)
