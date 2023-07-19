local a = require "plenary.async_lib.tests"

a.describe("plugin-loader", function()
    local plugins = require("qvim.core").plugins
    local core = require("qvim.core")
    local core_util = require("qvim.core.util")
    local manager = require("qvim.core.manager")
    local util_t = require("qvim.utils.fn_t")

    pcall(function()
        qvim.log.level = "debug"
    end)

    a.it("should be able to load full spec without errors", function()
        local specs = core.load_lazy_spec()
        manager:load(specs)
        for index, spec in ipairs(specs) do
            assert.truthy(util_t.any(plugins, function(plugin)
                return spec[1] == plugin
            end))
        end
    end)
end)
