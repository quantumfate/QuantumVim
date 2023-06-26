---@class dap.utils
local M = {}

local mappings = require("qvim.lang.dap.mappings")
local Log = require("qvim.integrations.log")
local fmt = string.format

---Get the package name of a debug adapter of a given `ft`
---@param ft string
---@return boolean, string|nil
function M.get_package_name(ft)
    local package_name = mappings.ft_to_mason_package[ft]
    if package_name then
        return true, package_name
    end
    return false, nil
end

---@param ft string
---@return Package|nil
function M.resolve_dap_package_from_mason(ft)
    local registry = require('mason-registry')
    local Optional = require('mason-core.optional')

    return Optional.of_nilable(mappings.ft_to_mason_package[ft]):map(function(package_name)
        local ok, pkg = pcall(registry.get_package, package_name)
        if ok then
            return pkg
        end
    end)
end

---comment
---@param ft any
function M.setup_debug_adapter(ft)

end

return M
