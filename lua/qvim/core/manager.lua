local manager = {}

local log = require("qvim.log")
local utils = require("qvim.utils")
local join_paths = utils.join_paths
local fmt = string.format

local plugins_dir = get_qvim_pack_dir()

local function ensure_plugins_in_rtp(lazy_install_dir)
	local rtp = vim.opt.rtp:get()
	local base_dir = get_qvim_data_dir():gsub("\\", "/")
	local idx_base = #rtp + 1
	for i, path in ipairs(rtp) do
		path = path:gsub("\\", "/")
		if path == base_dir then
			idx_base = i + 1
			break
		end
	end
	table.insert(rtp, idx_base, lazy_install_dir)
	table.insert(rtp, idx_base + 1, join_paths(plugins_dir, "*"))
	vim.opt.rtp = rtp

	vim.opt.packpath = vim.opt.rtp:get()
end

---Initzialize lazy vim as the plugin loader. This function will
---make sure to only bootstrap lazy vim when it has not been
---installed yet. On subsequent runs this function will only
---setup the cache for plugins and it will additionally prevent
---lazy vims setup function to be called twice.
---@param opts table optionally parse supported options by lazy vim
function manager:init(opts)
	opts = opts or {}

	local lazy_install_dir = opts.install_path
		or join_paths(vim.fn.stdpath("data"), "lazy", "lazy.nvim")

	if not utils.is_directory(lazy_install_dir) then
		print("Initializing first time setup")
		local core_plugins_dir = join_paths(get_qvim_state_dir(), "plugins")
		if utils.is_directory(core_plugins_dir) then
			vim.fn.mkdir(plugins_dir, "p")
			vim.loop.fs_rmdir(plugins_dir)
			require("qvim.utils").fs_copy(core_plugins_dir, plugins_dir)
		else
			vim.fn.system({
				"git",
				"clone",
				"--filter=blob:none",
				"--branch=stable",
				"https://github.com/folke/lazy.nvim.git",
				lazy_install_dir,
			})
			local default_snapshot_path =
				join_paths(get_qvim_state_dir(), "snapshots", "default.json")
			local snapshot = assert(
				vim.fn.json_decode(vim.fn.readfile(default_snapshot_path))
			)
			vim.fn.system({
				"git",
				"-C",
				lazy_install_dir,
				"checkout",
				snapshot["lazy.nvim"].commit,
			})
		end
	end

	ensure_plugins_in_rtp(lazy_install_dir)
	pcall(function()
		-- set a custom path for lazy's cache
		local lazy_cache = require("lazy.core.cache")
		lazy_cache.path = join_paths(get_qvim_cache_dir(), "lazy", "luac")
	end)
end

function manager:reset_cache()
	os.remove(require("lazy.core.cache").path)
end

---Loads all plugins and calls their setup function
---@param spec table|nil the plugin configuration table
function manager:load(spec)
	local startup_spec
	if os.getenv("QV_FIRST_TIME_SETUP") then
		startup_spec = require("qvim.core").load_lazy_spec_light()
	else
		startup_spec = require("qvim.core").load_lazy_spec()
	end
	spec = spec or startup_spec
	log:debug("loading plugins configuration")
	local lazy_available, lazy = pcall(require, "lazy")
	if not lazy_available then
		log:warn("skipping loading plugins until lazy.nvim is installed")
		return false
	end

	local status_ok = xpcall(function()
		local opts = {
			root = plugins_dir,
			install = {
				missing = true,
				colorscheme = { qvim.config.colorscheme, "habamax" },
			},
			ui = {
				border = "rounded",
			},
			git = {
				timeout = 120,
			},
			-- TODO I'm not exactly sure about this location
			lockfile = join_paths(get_qvim_rtp_dir(), "lazy-lock.json"),
			performance = {
				rtp = {
					reset = true,
				},
			},
			readme = {
				root = join_paths(get_qvim_rtp_dir(), "lazy", "readme"),
			},
		}

		lazy.setup(spec, opts)
	end, debug.traceback)

	if not status_ok then
		log:warn("problems detected while loading plugins' configurations")
		log:trace(debug.traceback())
		return false
	end

	return true
end

---Returns a list of plugins from the lazy spec
---@return table
function manager:get_integrations()
	local names = {}
	local integrations = require("qvim.core").load_lazy_spec_light()
	for _, spec in pairs(integrations) do
		if spec.enabled == true or spec.enabled == nil then
			table.insert(names, spec.name)
		end
	end
	return names
end

---Update, clean, install or sync the plugins from lazy. Stages and commits the lazy lock pre and post update.
---@param action string update, clean, install or sync
function manager:lazy_do_plugins(action)
	local actions =
		{ ["update"] = 1, ["clean"] = 2, ["install"] = 3, ["sync"] = 4 }
	local proxy = setmetatable({}, {
		__index = function(_, k)
			return actions[k:lower()]
		end,
		__newindex = function(_, _, _)
			return error("Immutable table")
		end,
	})
	local integrations = manager:get_integrations()
	log:trace(
		string.format(
			"[%s] Plugins: [%q]",
			action:upper(),
			table.concat(integrations, ", ")
		)
	)
	local git = require("qvim.utils.git").git_cmd
	git({
		args = {
			"commit",
			"-o",
			"lazy-lock.json",
			'-m " Lazy: lazy-lock.json state pre-' .. action .. '"',
		},
	})

	local opts = { wait = true, plugins = integrations }
	local mode = proxy[action]
	if mode == 1 then
		require("lazy").update(opts)
	elseif mode == 2 then
		require("lazy").clean(opts)
	elseif mode == 3 then
		require("lazy").install(opts)
	elseif mode == 4 then
		require("lazy").sync(opts)
	else
		log:error(fmt("Invalid mode '%s' for lazy update.", action))
	end

	git({
		args = {
			"commit",
			"-o",
			"lazy-lock.json",
			[[-m Lazy: lazy-lock.json state post-]] .. action,
		},
	})
end

function manager.ensure_plugins()
	log:debug("calling lazy.install()")
	require("lazy").install({ wait = true })
end

return manager
