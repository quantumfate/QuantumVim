local Log = require("qvim.log")
function _G.in_headless_mode()
	return #vim.api.nvim_list_uis() == 0
end

---Checks whether a integration provides a configuration file in `qvim.integrations`
---@param integration string
---@return boolean
function _G.integration_provides_config(integration)
	if type(integration) == "string" then
		local integration_file = "qvim.integrations." .. integration
		local does_exist, _ = pcall(require, integration_file)

		return does_exist
	else
		Log:warn(
			string.format(
				"Lookup for an existing configuration file failed because argument was '%s' but must be string.",
				type(integration)
			)
		)
		return false
	end
end
