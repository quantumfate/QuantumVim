local M = {}

function _G.in_headless_mode()
    return #vim.api.nvim_list_uis() == 0
end

if vim.fn.has "nvim-0.9" ~= 1 then
    vim.notify(
        "Please upgrade your Neovim base installation. This configuration requires v0.9+",
        vim.log.levels.WARN
    )
    vim.wait(5000, function()
        ---@diagnostic disable-next-line: redundant-return-value
        return false
    end)
    vim.cmd "cquit"
end

-- Path based on os
local uv = vim.loop
local path_sep = uv.os_uname().version:match "Windows" and "\\" or "/"

---Join path segments that were passed as input
---@return string
function _G.join_paths(...)
    local result = table.concat({ ... }, path_sep)
    return result
end

_G.require_clean = require("qvim.utils.modules").require_clean
_G.require_safe = require("qvim.utils.modules").require_safe
_G.reload = require("qvim.utils.modules").reload

---Get the full path to `$QUANTUMVIM_CONFIG_DIR`
---@return string|nil
function _G.get_qvim_config_dir()
    local qvim_config_dir = os.getenv "QUANTUMVIM_CONFIG_DIR"
    if not qvim_config_dir then
        return vim.call("stdpath", "config")
    end
    return qvim_config_dir
end

---Get the full path to `$QUANTUMVIM_STATE_DIR`
---@return string|nil
function _G.get_qvim_state_dir()
    local qvim_state_dir = os.getenv "QUANTUMVIM_STATE_DIR"
    if not qvim_state_dir then
        return vim.call("stdpath", "state")
    end
    return qvim_state_dir
end

---Get the full path to `$QUANTUMVIM_DATA_DIR`
---@return string|nil
function _G.get_qvim_data_dir()
    local qvim_data_dir = os.getenv "QUANTUMVIM_DATA_DIR"
    if not qvim_data_dir then
        return vim.call("stdpath", "data")
    end
    return qvim_data_dir
end

---Get the full path to `$QUANTUMVIM_CACHE_DIR`
---@return string
function _G.get_qvim_cache_dir()
    local qvim_cache_dir = os.getenv "QUANTUMVIM_CACHE_DIR"
    if not qvim_cache_dir then
        return vim.call("stdpath", "cache")
    end
    return qvim_cache_dir
end

---Initialize the `&runtimepath` variables, load the globals and prepare for startup
---@return table
function M:init()
    local utils = require "qvim.utils"
    self.qvim_config_dir = get_qvim_config_dir()
    self.qvim_cache_dir = get_qvim_cache_dir()
    self.pack_dir = join_paths(get_qvim_data_dir(), "lazy")
    self.lazy_install_dir =
        join_paths(self.pack_dir, "lazy.nvim")

    local structlog_path = join_paths(self.pack_dir, "structlog")
    if not os.getenv("QV_FIRST_TIME_SETUP") and utils.is_directory(structlog_path) then
        vim.opt.rtp:append(structlog_path)
        require("qvim.log"):init_pre_setup()
    end

    require("qvim.core.manager"):init {
        package_root = self.pack_dir,
        install_path = self.lazy_install_dir,
    }
    require("qvim.config"):init()

    print(vim.inspect(vim.opt.rtp:get()))
    return self
end

function M:setup()
    local utils = require "qvim.utils"
    self.qvim_config_dir = get_qvim_config_dir()
    self.qvim_cache_dir = get_qvim_cache_dir()
    self.pack_dir = join_paths(get_qvim_data_dir(), "lazy")
    self.lazy_install_dir =
        join_paths(self.pack_dir, "lazy.nvim")
    print(vim.inspect(vim.opt.rtp:get()))

    print(vim.inspect(vim.opt.rtp:get()))
    local structlog_path = join_paths(self.pack_dir, "structlog")

    local manager = require "qvim.core.manager"
    manager:load()

    require("qvim.config"):setup()

    if utils.is_directory(structlog_path) then
        require("qvim.log"):init_post_setup()
    end
    require("qvim.core.plugins.mason").bootstrap()
end

---Update qvimVim
---pulls the latest changes from github and, resets the startup cache
function M:update()
    require("qvim.log"):info "Trying to update QuantumVim..."
    vim.schedule(function()
        reload("qvim.utils.hooks").run_pre_update()
        local ret = reload("qvim.utils.git").update_base_qvim()
        if ret then
            reload("qvim.utils.hooks").run_post_update()
        end
    end)
end

return M
