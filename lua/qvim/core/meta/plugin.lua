---@class core_meta_plugin
local core_meta_plugin = {}

---Generic setup function for plugins that don't implement anything special.
---Can be called from tables that inherit from plugin with: `getmetatable(self).__index.setup(self)`
---@param self T
function core_meta_plugin:setup()
    local core_error_util = require("qvim.core.error")
    local log = require "qvim.log"
    local fmt = string.format

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
        print(self.name)
        log:error(
            fmt(
                "Setup from '%s' configured by '%s' not called. More information in logs.",
                self.main,
                self.name
            )
        )
    end
end

return core_meta_plugin
