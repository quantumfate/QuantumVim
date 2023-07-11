---@class core_meta_parent
local core_mata_parent = {}

---@param self AbstractParent|AbstractPlugin
function core_mata_parent:setup()
    local log = require "qvim.log"
    local fmt = string.format
    print(self.main)
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

    if self.on_setup_start then
        self.on_setup_start(self, plugin)
    end

    local setup_ok, _ = pcall(plugin.setup, self.options)
    if setup_ok then
        log:debug(
            fmt(
                "SUCCESS: Called setup function from '%s' configured by '%s'.",
                self.main,
                self.name
            )
        )
    else
        log:error(
            fmt(
                "Required Plugin: '%s'. The setup call of '%s' failed. Consult '%s' to see validate the configuration."
                .. "\n"
                .. "%s",
                self.main,
                self.name,
                self.url,
                debug.traceback()
            )
        )
    end

    if self.on_setup_done then
        self.on_setup_done(self, plugin)
    end
end

return core_mata_parent
