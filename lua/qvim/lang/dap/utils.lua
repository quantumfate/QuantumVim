---@class dap.utils
local M = {}

local mappings = require "qvim.lang.dap.mappings"
local shared_utils = require "qvim.lang.utils"

---Get the package name of a debug adapter of a given `ft`
---@param ft string
---@return boolean, string|nil
function M.get_package_name(ft)
    local package_name = mappings.ft_to_mason_dap_package[ft]
    if package_name then
        return true, package_name
    end
    return false, nil
end

---@param ft string
---@return Package|nil
function M.resolve_dap_package_from_mason(ft)
    local registry = require "mason-registry"
    local Optional = require "mason-core.optional"

    local optional = Optional.of_nilable(mappings.ft_to_mason_dap_package[ft])
        :map(function(package_name)
            local ok, pkg = pcall(registry.get_package, package_name)
            if ok then
                return pkg
            end
        end)

    return optional:or_else_get(function()
        return nil
    end)
end

---@param ft string
---@return Package|nil
function M.resolve_test_package_from_mason(ft)
    local registry = require "mason-registry"
    local Optional = require "mason-core.optional"

    local optional = Optional.of_nilable(mappings.ft_to_mason_test_package[ft])
        :map(function(package_name)
            local ok, pkg = pcall(registry.get_package, package_name)
            print(package_name)
            if ok then
                return pkg
            end
        end)

    return optional:or_else_get(function()
        return nil
    end)
end

---Invokes the specific debug adapter setup on a given `ft`
---@param ft string
function M.setup_debug_adapter(ft)
    local ft_extension_name = shared_utils.get_ft_bridge_proxy()[ft]
    local ok_ft_ext, ft_extension =
        pcall(require, "qvim.lang.dap.filetypes." .. ft_extension_name)
    if ok_ft_ext and ft_extension then
        ft_extension.setup(ft)
    end
end

return M
