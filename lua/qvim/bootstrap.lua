local M = {}

local in_headless = #vim.api.nvim_list_uis() == 0

if vim.fn.has("nvim-0.8") ~= 1 then
	vim.notify("Please upgrade your Neovim base installation. This configuration requires v0.8+", vim.log.levels.WARN)
	vim.wait(5000, function()
		---@diagnostic disable-next-line: redundant-return-value
		return false
	end)
	vim.cmd("cquit")
end

-- Path based on os
local uv = vim.loop
local path_sep = uv.os_uname().version:match("Windows") and "\\" or "/"

---Join path segments that were passed as input
---@return string
function _G.join_paths(...)
	local result = table.concat({ ... }, path_sep)
	return result
end

_G.require_clean = require("qvim.utils.modules").require_clean
_G.require_safe = require("qvim.utils.modules").require_safe
_G.reload = require("qvim.utils.modules").reload

---Get the full path to `$QUANTUMVIM_DIR`
---@return string|nil
function _G.get_qvim_rtp_dir()
	local qvim_dir = os.getenv("QUANTUMVIM_DIR")
	if not qvim_dir then
		return vim.call("stdpath", "config")
	end
	return qvim_dir
end

---Get the full path to `$QUANTUMVIM_CACHE_DIR`
---@return string
function _G.get_cache_dir()
	local qvim_cache_dir = os.getenv("QUANTUMVIM_CACHE_DIR")
	if not qvim_cache_dir then
		return vim.call("stdpath", "cache")
	end
	return qvim_cache_dir
end

---Initialize the `&runtimepath` variables, load the globals and prepare for startup
---@return table
function M:init()
	self.qvim_rtp_dir = get_qvim_rtp_dir()
	self.cache_dir = get_cache_dir()
	self.pack_dir = join_paths(self.qvim_rtp_dir, "site", "pack")
	self.lazy_install_dir = join_paths(self.pack_dir, "lazy", "opt", "lazy.nvim")

	require("qvim.global")

	---@meta overridden to use QUANTUMVIM_CACHE_DIR instead, since a lot of plugins call this function internally
	---NOTE: changes to "data" are currently unstable, see #2507
	---@diagnostic disable-next-line: duplicate-set-field
	vim.fn.stdpath = function(what)
		if what == "cache" then
			return _G.get_cache_dir()
		end
		return vim.call("stdpath", what)
	end

	vim.opt.rtp:remove(join_paths(vim.call("stdpath", "data"), "site"))
	vim.opt.rtp:remove(join_paths(vim.call("stdpath", "data"), "site", "after"))
	-- vim.opt.rtp:prepend(join_paths(self.runtime_dir, "site"))
	vim.opt.rtp:append(join_paths(self.qvim_rtp_dir, "after"))
	vim.opt.rtp:append(join_paths(self.qvim_rtp_dir, "site", "after"))

	vim.opt.rtp:remove(vim.call("stdpath", "config"))
	vim.opt.rtp:remove(join_paths(vim.call("stdpath", "config"), "after"))
	vim.opt.rtp:prepend(self.qvim_rtp_dir)
	vim.opt.rtp:append(join_paths(self.qvim_rtp_dir, "after"))

	vim.opt.packpath = vim.opt.rtp:get()

	require("qvim.integrations.loader"):init({
		package_root = self.pack_dir,
		install_path = self.lazy_install_dir,
	})

	require("qvim.global")
	require("qvim.config"):init()
	require("qvim.integrations.mason").bootstrap()

	return self
end

---Update qvimVim
---pulls the latest changes from github and, resets the startup cache
function M:update()
	require("qvim.integrations.log"):info("Trying to update QuantumVim...")
	vim.schedule(function()
		reload("qvim.utils.hooks").run_pre_update()
		local ret = reload("qvim.utils.git").update_base_qvim()
		if ret then
			reload("qvim.utils.hooks").run_post_update()
		end
	end)
end

return M
