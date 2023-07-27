local a = require "plenary.async_lib.tests"
local uv = vim.loop
local home_dir = uv.os_homedir()

a.describe("initial start", function()
    local qvim_config_path = get_qvim_config_dir()
    local qvim_data_path = get_qvim_data_dir()
    local qvim_cache_path = get_qvim_cache_dir()
    local qvim_state_path = get_qvim_state_dir()

    a.it("NVIM_APPNAME variable should be set", function()
        assert.truthy(os.getenv("NVIM_APPNAME") ~= nil)
    end)

    a.it("should be able to use QuantumVim directories using vim.fn", function()
        assert.equal(qvim_config_path, vim.fn.stdpath("config"))
        assert.equal(qvim_data_path, vim.fn.stdpath("data"))
        assert.equal(qvim_cache_path, vim.fn.stdpath("cache"))
        assert.equal(qvim_state_path, vim.fn.stdpath("state"))
    end)

    a.it("should NOT be able to retrieve default neovim directories", function()
        local xdg_config = os.getenv "XDG_CONFIG_HOME" or join_paths(home_dir, ".config")
        assert.truthy(join_paths(xdg_config, "nvim") ~= vim.call("stdpath", "config"))
    end)

    a.it("should be able to read lazy directories from rtp", function()
        local rtp_list = vim.opt.rtp:get()
        assert.truthy(vim.tbl_contains(rtp_list, join_paths(get_lazy_rtp_dir(), "*")))
        assert.truthy(vim.tbl_contains(rtp_list, get_lazy_rtp_dir() .. "/lazy.nvim"))
    end)

    a.it("should be able to run treesitter without errors", function()
        assert.truthy(vim.treesitter.highlighter.active)
    end)

    a.it("should be able to pass basic checkhealth without errors", function()
        vim.cmd "set cmdheight&"
        vim.cmd "checkhealth nvim"
        local errmsg = vim.fn.eval "v:errmsg"
        local exception = vim.fn.eval "v:exception"
        assert.equal("", errmsg) -- v:errmsg was not updated.
        assert.equal("", exception)
    end)
end)
