---@class core_loader
local core_loader = {}

local log = require "qvim.log"
local fmt = string.format
local core_loader_util = require "qvim.core.loader.util"
local core_util = require "qvim.core.util"

local plugin_spec_path = "qvim.core.loader.specs."

---Populates a lazy spec for a plugin by a given `plugin_name` and `url`. Lazy
---specs for dependencies of the plugin will be populated recursively.
---@param plugin_name string
---@param url string
---@param first_time_setup boolean
---@param hr_name string matching filenames will be hooked from specs
---@param has_parent string? the name of
---@return table? plugin_spec whether the plugin is a dependency and the name that indicates the parent
function core_loader.new(plugin_name, url, first_time_setup, hr_name, has_parent)
    vim.validate {
        plugin_name = { plugin_name, "s", false },
        url = { url, "s", false },
        first_time_setup = { first_time_setup, "b", false },
        hr_name = { hr_name, "s", false },
    }

    local spec_require_path = plugin_spec_path .. hr_name
    local plugin_spec
    if first_time_setup then
        plugin_spec =
            core_loader_util.minimal_plugin_spec(url, hr_name, spec_require_path)
    else
        local default_spec
        if has_parent then
            default_spec = core_loader_util.extension_or_standalone_dependency_spec(
                has_parent,
                plugin_name,
                hr_name,
                url
            )
        else
            default_spec = core_loader_util.core_plugin_spec_or_default(
                plugin_name,
                url,
                hr_name
            )
        end
        plugin_spec = core_loader_util.load_lazy_config_spec_for_plugin(
            spec_require_path,
            { __index = default_spec }
        )
    end

    if plugin_spec.dependencies then
        local dep_spec = {}
        for _, dep in pairs(plugin_spec.dependencies) do
            if type(dep) == "string" then
                local dep_ok, dep_name, dep_hr_name =
                    core_util.is_valid_plugin_name(dep)
                if dep_ok and dep_name and dep_hr_name then
                    dep_spec[#dep_spec + 1] = core_loader.new(
                        dep_name,
                        dep,
                        first_time_setup,
                        dep_hr_name,
                        plugin_name
                    )
                else
                    log:debug(
                        fmt(
                            "[core.loader] Failed to load spec for dependency '%s', of the plugin '%s'.",
                            dep,
                            plugin_name
                        )
                    )
                end
            elseif type(dep) == "table" then
                dep_spec[#dep_spec + 1] = dep
            else
                log:debug(
                    fmt(
                        "[core.loader] Unknown dependency listed in '%s'. Should be type string or table but was '%s'.",
                        plugin_name,
                        type(dep)
                    )
                )
            end
        end
        plugin_spec.dependencies = dep_spec
    end

    return plugin_spec
end

return core_loader
