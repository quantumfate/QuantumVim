---@return string
local function vim_call(what)
    return vim.call("stdpath", what)
end

function _G.in_headless_mode()
    return #vim.api.nvim_list_uis() == 0
end

---Path concatenation without library method calls. Works for windows
---and unix like systems.
---@param ... string
---@return string
function _G.join_paths(...)
    local path_sep = vim.loop.os_uname().version:match "Windows" and "\\" or "/"
    local res = ""
    local num = select("#", ...)
    for idx, element in ipairs({ ... }) do
        res = res .. element
        if idx < num then
            res = res .. path_sep
        end
    end
    return res
end

---Get the full path to `$QUANTUMVIM_DIR`
---@return string|nil
function _G.get_qvim_dir()
    local qvim_dir = os.getenv("QUANTUMVIM_DIR")
    if not qvim_dir then
        return vim_call("config")
    end
    return qvim_dir
end

---Get the full path to `$QUANTUMVIM_CACHE_DIR`
---@return string|nil
function _G.get_cache_dir()
    local qvim_cache_dir = os.getenv("QUANTUMVIM_CACHE_DIR")
    if not qvim_cache_dir then
        return vim_call("cache")
    end
    return qvim_cache_dir
end

---Initialize the `&runtimepath` variables, load the globals and prepare for startup

local qvim_dir = get_qvim_dir()
local cache_dir = get_cache_dir()
local pack_dir = join_paths(qvim_dir, "site", "pack")
local lazy_install_dir = join_paths(pack_dir, "lazy", "opt", "lazy.nvim")

---@meta overridden to use QUANTUMVIM_CACHE_DIR instead, since a lot of plugins call this function internally
---NOTE: changes to "data" are currently unstable, see #2507
---@diagnostic disable-next-line: duplicate-set-field
vim.fn.stdpath = function(what)
    if what == "cache" then
        return _G.get_cache_dir()
    end
    return vim.fn.stdpath(what)
end

if os.getenv "QUANTUMVIM_DIR" then
    -- data dir
    vim.opt.rtp:remove(_G.join_paths(vim.fn.stdpath("data"), "site"))
    vim.opt.rtp:remove(_G.join_paths(vim.fn.stdpath("data") "site", "after"))
    vim.opt.rtp:append(_G.join_paths(qvim_dir, "after"))
    vim.opt.rtp:append(_G.join_paths(qvim_dir, "site", "after"))

    -- config dir
    vim.opt.rtp:remove(vim.fn.stdpath("config"))
    vim.opt.rtp:remove(_G.join_paths(vim.fn.stdpath("config"), "after"))
    vim.opt.rtp:prepend(qvim_dir)
    vim.opt.rtp:append(_G.join_paths(qvim_dir, "after"))

    vim.opt.packpath = vim.opt.rtp:get()
end

require("qvim.core.manager"):init({
    package_root = pack_dir,
    install_path = lazy_install_dir,
})

require("qvim.config"):init()
require("qvim.core.plugins.mason").bootstrap()
