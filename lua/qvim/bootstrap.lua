---@diagnostic disable: param-type-mismatch, return-type-mismatch
local M = {}
M.__index = M

function _G.in_headless_mode()
	return #vim.api.nvim_list_uis() == 0
end

if vim.fn.has("nvim-0.9") ~= 1 then
	vim.notify(
		"Please upgrade your Neovim base installation. This configuration requires v0.9+",
		vim.log.levels.WARN
	)
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

---Get the full path to `$QUANTUMVIM_CONFIG_DIR`
---@return string
function _G.get_qvim_config_dir()
	local qvim_config_dir = os.getenv("QUANTUMVIM_CONFIG_DIR")
	if not qvim_config_dir then
		return vim.call("stdpath", "config")
	end
	return qvim_config_dir
end

---Get the full path to `$QUANTUMVIM_LOG_DIR`
---@return string
function _G.get_qvim_log_dir()
	local qvim_log_dir = os.getenv("QUANTUMVIM_LOG_DIR")
	if not qvim_log_dir then
		return vim.call("stdpath", "log")
	end
	return qvim_log_dir
end

---Get the full path to `$QUANTUMVIM_STATE_DIR`
---@return string
function _G.get_qvim_state_dir()
	local qvim_state_dir = os.getenv("QUANTUMVIM_STATE_DIR")
	if not qvim_state_dir then
		return vim.call("stdpath", "state")
	end
	return qvim_state_dir
end

---Get the full path to `$QUANTUMVIM_RTP_DIR`
---@return string
function _G.get_qvim_rtp_dir()
	return os.getenv("QUANTUMVIM_RTP_DIR")
end

---Get the full path to `$QUANTUMVIM_DATA_DIR`
---@return string
function _G.get_qvim_data_dir()
	local qvim_data_dir = os.getenv("QUANTUMVIM_DATA_DIR")
	if not qvim_data_dir then
		return vim.call("stdpath", "data")
	end
	return qvim_data_dir
end

---Get the full path to `$QUANTUMVIM_CACHE_DIR`
---@return string
function _G.get_qvim_cache_dir()
	local qvim_cache_dir = os.getenv("QUANTUMVIM_CACHE_DIR")
	if not qvim_cache_dir then
		return vim.call("stdpath", "cache")
	end
	return qvim_cache_dir
end

---Get the full path to `$QUANTUMVIM_PACK_DIR`
---@return string
function _G.get_qvim_pack_dir()
	return os.getenv("QUANTUMVIM_PACK_DIR")
end

---Get the full path to `$QUANTUMVIM_STRUCTLAG_DIR`
---@return string
function _G.get_qvim_structlog_dir()
	return os.getenv("QUANTUMVIM_STRUCTLOG_DIR")
end

M.qvim_config_dir = get_qvim_config_dir()
M.qvim_state_dir = get_qvim_state_dir()
M.qvim_rtp_dir = get_qvim_rtp_dir()
M.qvim_cache_dir = get_qvim_cache_dir()
M.qvim_data_dir = get_qvim_data_dir()
M.qvim_log_dir = get_qvim_log_dir()
M.qvim_pack_dir = get_qvim_pack_dir()
M.lazy_install_dir = join_paths(M.qvim_pack_dir, "lazy.nvim")

function _G.get_lazy_rtp_dir()
	return M.qvim_pack_dir
end

---Initialize the `&runtimepath` variables, load the globals and prepare for startup
---@return table
function M:init()
	---@meta overridden
	---@param what any
	---@return string
	vim.fn.stdpath = function(what)
		if what == "cache" then
			return get_qvim_cache_dir()
		elseif what == "rtp" then
			return get_qvim_rtp_dir()
		elseif what == "state" then
			return get_qvim_state_dir()
		elseif what == "data" then
			return get_qvim_data_dir()
		elseif what == "config" then
			return get_qvim_config_dir()
		elseif what == "log" then
			return get_qvim_log_dir()
		elseif what == "pack" then
			return get_qvim_pack_dir()
		elseif what == "structlog" then
			return get_qvim_structlog_dir()
		else
			return vim.call("stdpath", what)
		end
	end

	local log_path = join_paths(self.qvim_pack_dir, "structlog")
	vim.opt.rtp:prepend(log_path)

	local log = require("qvim.log")
	log.setup()

	require("qvim.core.manager"):init({
		package_root = self.qvim_pack_dir,
		install_path = self.lazy_install_dir,
	})

	vim.opt.rtp = self:bootstrap()

	require("qvim.config"):init()

	return self
end

function M:setup()
	local manager = require("qvim.core.manager")
	manager:load()
	require("qvim.core.plugins.mason").bootstrap()
	local log = require("qvim.log")
	log.update()
end

--Modifies the runtimepath by removing standard paths from `vim.call("stdpath", what)` with `vim.fn.stdpath(what)`
---@param stds string[]|nil @default: { "config", "data" }
---@param expands string[][]|nil @default: { {}, { "site", "after" }, { "site" }, { "after" } }
---@return vim.opt.runtimepath
function M:bootstrap(stds, expands)
	stds = stds or { "config", "data" }
	expands = expands or { {}, { "site", "after" }, { "site" }, { "after" } }
	---@type vim.opt.runtimepath
	local rtp_paths = vim.opt.rtp:get()
	local rtp = vim.opt.rtp

	for _, what in ipairs(stds) do
		for _, expand in ipairs(expands) do
			if #expand == 0 then
				if vim.tbl_contains(rtp_paths, vim.call("stdpath", what)) then
					-- remove
					rtp:remove(vim.call("stdpath", what))
				end
				if not vim.tbl_contains(rtp_paths, vim.fn.stdpath(what)) then
					-- add
					rtp:prepend(vim.fn.stdpath(what))
				end
			else
				if
				-- remove
					vim.tbl_contains(
						rtp_paths,
						_G.join_paths(vim.call("stdpath", what), unpack(expand))
					)
				then
					rtp:remove(
						_G.join_paths(vim.call("stdpath", what), unpack(expand))
					)
				end
				if
					not vim.tbl_contains(
						rtp_paths,
						_G.join_paths(vim.fn.stdpath(what), unpack(expand))
					)
				then
					-- add
					rtp:prepend(
						_G.join_paths(vim.fn.stdpath(what), unpack(expand))
					)
				end
			end
		end
	end
	return rtp
end

---Update qvimVim
---pulls the latest changes from github and, resets the startup cache
function M:update()
	require("qvim.log"):info("Trying to update QuantumVim...")
	vim.schedule(function()
		reload("qvim.utils.hooks").run_pre_update()
		local ret = reload("qvim.utils.git").update_base_qvim()
		if ret then
			reload("qvim.utils.hooks").run_post_update()
		end
	end)
end

return M
