---@class core_meta_ext
local core_meta_ext = {}

---@param self AbstractExtension
function core_meta_ext:setup_ext()
    local core_error_util = require("qvim.core.error")
    local log = require "qvim.log"
    local fmt = string.format

    ---@type AbstractParent
    local parent = getmetatable(self).__index

    local status_ok, plugin = pcall(require, self.main)
    if not status_ok then
        log:warn(
            fmt(
                "The extension '%s' from '%s' could not be loaded with '%s'. Check 'RTP' and 'main'.",
                self.name,
                parent.name,
                self.main
            )
        )
    end

    if self.on_setup_start then
        self.on_setup_start(self, plugin)
    end

    local function error_handler_closure(err)
        core_error_util.setup_error_handler(self, err)
    end

    local setup_ok, _ = xpcall(plugin.setup, error_handler_closure, self.options)
    if setup_ok then
        log:debug(
            fmt(
                "SUCCESS: Called setup function from the extension '%s' of '%s' configured by '%s'.",
                self.name,
                parent.name,
                self.main
            )
        )
    else
        log:trace(
            fmt(
                "Setup from the extension '%s' of '%s' configured by '%s' not called. More information in logs.",
                self.name,
                parent.name,
                self.main
            )
        )
    end

    if self.on_setup_done then
        self.on_setup_done(self, plugin)
    end
end

return core_meta_ext
