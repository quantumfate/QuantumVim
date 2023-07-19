local a = require "plenary.async_lib.tests"

a.describe("config-loader", function()
    local plugins = require("qvim.core").plugins
    local core = require("qvim.core")
    local core_util = require("qvim.core.util")
    local manager = require("qvim.core.manager")

    before_each(function()
        vim.cmd [[
	    let v:errmsg = ""
      let v:errors = []
    ]]
    end)

    after_each(function()
        local errmsg = vim.fn.eval "v:errmsg"
        local exception = vim.fn.eval "v:exception"
        local errors = vim.fn.eval "v:errors"
        assert.equal("", errmsg)
        assert.equal("", exception)
        assert.True(vim.tbl_isempty(errors))
    end)


    a.it("All plugins should be able to pass name validation", function()
        for _, plugin in ipairs(plugins) do
            local isvalid, plugin_name, hr_name = core_util.is_valid_plugin_name(plugin)
            assert.truthy(isvalid and plugin_name ~= nil and hr_name ~= nil)
        end
    end)

    a.it("Should be able to configure all plugins after fetching light spec without errors", function()
        manager:load(core.load_lazy_spec_light())
        core.init_plugin_configurations()
        for _, plugin in ipairs(plugins) do
            local _, plugin_name, _ = core_util.is_valid_plugin_name(plugin)
            assert.truthy(vim.tbl_contains(qvim.plugins, plugin_name))
        end
    end)
end)
