---@class core_meta_parent
local core_mata_parent = {}

---@param self AbstractParent|AbstractPlugin
function core_mata_parent:setup()
    local core_error_util = require("qvim.core.error")
    local log = require "qvim.log"
    local fmt = string.format

    if self.conf_extensions then
        for _, ext in pairs(self.conf_extensions) do
            pcall(getmetatable(ext).__index.setup_ext, ext)
        end
    end

    local status_ok, plugin = pcall(require, self.main)
    if not status_ok then
        log:warn(
            fmt(
                "The plugin '%s' could not be loaded with '%s'. Check 'RTP' and 'main'.",
                self.name,
                self.main
            )
        )
    end

    local function error_handler_closure(err)
        core_error_util.setup_error_handler(self, err)
    end

    local setup_ok, _ = xpcall(plugin.setup, error_handler_closure, self.options)
    if setup_ok then
        log:debug(
            fmt(
                "SUCCESS: Called setup function from '%s' configured by '%s'.",
                self.main,
                self.name
            )
        )
    else
        log:trace(
            fmt(
                "Setup from '%s' configured by '%s' not called. More information in logs.",
                self.main,
                self.name
            )
        )
    end
end

return core_mata_parent
