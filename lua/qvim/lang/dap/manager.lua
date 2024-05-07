---@class dap.manager
local M = {}

local log = require("qvim.log").dap
local shared_util = require("qvim.lang.utils")
local utils = require("qvim.lang.dap.utils")
local fmt = string.format

function M.setup(filetype)
	local package_available, package_name = utils.get_package_name(filetype)

	local custom_spec_ok, custom_package, package

	custom_spec_ok, custom_package = shared_util.register_custom_mason_package(
		filetype,
		"qvim.lang.dap.packages"
	)

	if custom_spec_ok then
		package = custom_package
	elseif package_available then
		package = utils.resolve_dap_package_from_mason(filetype)
	else
		log.debug(
			fmt(
				"No mason debug adapter package found for the filetype '%s'.",
				filetype
			)
		)
		return
	end

	if package then
		shared_util.try_install_and_setup_mason_package(
			package,
			fmt("debug adapter on filetype %s", filetype),
			utils.setup_debug_adapter,
			{ filetype }
		)
	else
		log.error(
			fmt(
				"The debug adapter package '%s' from the filetype '%s' is not a package supported by mason.",
				package_name,
				filetype
			)
		)
		return
	end
end

return M
