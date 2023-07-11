local log = require("qvim.log")
local fmt = string.format
local core_error_util = {}

---Error handler plugin configuration.
---@param err string
---@param hr_name string
---@param plugin_path string
function core_error_util.error_handler(err, hr_name, plugin_path)
    if err:match(".*" .. plugin_path .. ".*") then
        log:debug(fmt("No configuration file found for '%s'.", hr_name))
    elseif err:match(".*module .* not found.*") then
        log:debug(
            fmt(
                "A module in the configuration of '%s' caused an error. Is this first time setup? If it's not some plugin in '%s' is missing or malfunctioning require path was used.",
                hr_name,
                plugin_path
            )
        )
    else
        log:error(
            fmt(
                "Unknown error occured during configuration of '%s' in '%s'.",
                hr_name,
                plugin_path
            )
        )
    end
end

---Error handler plugin extension configuration.
---@param err string
---@param hr_name_parent string
---@param hr_name_ext string
---@param plugin_path string
function core_error_util.error_handler_ext(err, hr_name_parent, hr_name_ext, plugin_path)
    if err:match(".*'" .. plugin_path .. "'.*") then
        log:debug(fmt("No configuration file found for extension '%s' of '%s'.", hr_name_ext, hr_name_parent))
    elseif err:match ".*module '.*' not found.*" then
        log:debug(
            fmt(
                "A module in the configuration of the '%s' extension '%s' caused an error. Is this first time setup? If it's not some plugin in '%s' is missing or malfunctioning require path was used.",
                hr_name_parent,
                hr_name_ext,
                plugin_path
            )
        )
    else
        log:error(
            fmt(
                "Unknown error occured during configuration of the '%s' extension '%s' in '%s'.",
                hr_name_parent,
                hr_name_ext,
                plugin_path
            )
        )
    end
end

---comment
---@param self table
---@param err any
function core_error_util.setup_error_handler(self, err)
    log:debug(
        fmt(
            "Required Plugin: '%s'. The setup call of '%s' failed. Consult '%s' to see validate the configuration."
            .. "\n"
            .. "%s"
            .. "\n"
            .. "%s",
            self.main,
            self.name,
            self.url,
            err,
            debug.traceback()
        )
    )
end

return core_error_util
