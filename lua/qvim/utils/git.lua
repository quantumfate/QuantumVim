local M = {}

local log = require("qvim.log").qvim
local fn_t = require("qvim.utils.fn_t")
local fmt = string.format
local if_nil = vim.F.if_nil

function M.git_cmd(opts)
	local plenary_loaded, Job = pcall(require, "plenary.job")
	if not plenary_loaded then
		return 1, { "" }
	end

	opts = opts or {}
	opts.cwd = opts.cwd or get_qvim_config_dir()

	local stderr = {}
	local stdout, ret = Job:new({
		command = "git",
		args = opts.args,
		cwd = opts.cwd,
		on_stderr = function(_, data)
			table.insert(stderr, data)
		end,
	}):sync()

	if not vim.tbl_isempty(stderr) then
		log.debug(fn_t.join(stderr, "\n"))
	end

	if not vim.tbl_isempty(stdout) then
		log.debug(stdout)
	end

	return ret, stdout, stderr
end

local function safe_deep_fetch()
	local ret, result, error =
		M.git_cmd({ args = { "rev-parse", "--is-shallow-repository" } })
	if ret ~= 0 then
		log.error(vim.inspect(error))
		return
	end
	-- git fetch --unshallow will cause an error on a complete clone
	local fetch_mode = result[1] == "true" and "--unshallow" or "--all"
	ret = M.git_cmd({ args = { "fetch", fetch_mode } })
	if ret ~= 0 then
		log.error(
			fmt(
				"Git fetch %s failed! Please pull the changes manually in %s",
				fetch_mode,
				get_qvim_config_dir()
			)
		)
		return
	end
	if fetch_mode == "--unshallow" then
		ret = M.git_cmd({ args = { "remote", "set-branches", "origin", "*" } })
		if ret ~= 0 then
			log.error(
				fmt(
					"Git fetch %s failed! Please pull the changes manually in %s",
					fetch_mode,
					get_qvim_config_dir()
				)
			)
			return
		end
	end
	return true
end

---pulls the latest changes from github
function M.update_base_qvim()
	log.info("Checking for updates")

	if not vim.loop.fs_access(get_qvim_config_dir(), "w") then
		log.warn(
			fmt(
				"QuantumVim update aborted! cannot write to %s",
				get_qvim_config_dir()
			)
		)
		return
	end

	if not safe_deep_fetch() then
		return
	end

	local ret

	ret = M.git_cmd({ args = { "diff", "--quiet", "@{upstream}" } })
	if ret == 0 then
		log.info("QuantumVim is already up-to-date")
		return
	end

	ret = M.git_cmd({ args = { "merge", "--ff-only", "--progress" } })
	if ret ~= 0 then
		log.error(
			"Update failed! Please pull the changes manually in "
				.. get_qvim_config_dir()
		)
		return
	end

	return true
end

---Switch Lunarvim to the specified development branch
---@param branch string
function M.switch_qvim_branch(branch)
	if not safe_deep_fetch() then
		return
	end
	local args = { "switch", branch }

	if branch:match("^[0-9]") then
		-- avoids producing an error for tags
		vim.list_extend(args, { "--detach" })
	end

	local ret = M.git_cmd({ args = args })
	if ret ~= 0 then
		log.error(
			"Unable to switch branches! Check the log for further information"
		)
		return
	end
	return true
end

---Get the current Lunarvim development branch
---@return string|nil
function M.get_qvim_branch()
	local _, results =
		M.git_cmd({ args = { "rev-parse", "--abbrev-ref", "HEAD" } })
	local branch = if_nil(results[1], "")
	return branch
end

---Get currently checked-out tag of Lunarvim
---@return string
function M.get_qvim_tag()
	local args = { "describe", "--tags", "--abbrev=0" }

	local _, results = M.git_cmd({ args = args })
	local tag = if_nil(results[1], "")
	return tag
end

---Get currently running version of Lunarvim
---@return string
function M.get_qvim_version()
	local current_branch = M.get_qvim_branch()

	local qvim_version
	if current_branch ~= "HEAD" or "" then
		qvim_version = current_branch .. "-" .. M.get_qvim_current_sha()
	else
		qvim_version = "v" .. M.get_qvim_tag()
	end
	return qvim_version
end

---Get the commit hash of currently checked-out commit of Lunarvim
---@return string|nil
function M.get_qvim_current_sha()
	local _, log_results =
		M.git_cmd({ args = { "log", "--pretty=format:%h", "-1" } })
	local abbrev_version = if_nil(log_results[1], "")
	return abbrev_version
end

return M
