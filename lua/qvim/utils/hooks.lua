local M = {}

local log = require("qvim.log").qvim
local in_headless = #vim.api.nvim_list_uis() == 0
local fmt = string.format
local plugin_loader = require("qvim.core.manager")

function M.run_pre_update()
	log.debug("Starting pre-update hook")
end

function M.run_pre_reload()
	log.debug("Starting pre-reload hook")
end

-- TODO: convert to lazy.nvim
-- function M.run_on_packer_complete()
-- -- FIXME(kylo252): nvim-tree.lua/lua/nvim-tree/view.lua:442: Invalid window id
-- vim.g.colors_name = qvim.colorscheme
-- pcall(vim.cmd.colorscheme, qvim.colorscheme)
-- end

function M.run_post_reload()
	log.debug("Starting post-reload hook")
end

---Uses cache invalidation to reset any startup cache files used by lazy.nvim.
---It also forces regenerating any template ftplugin files
---Tip: Useful for clearing any outdated settings
function M.reset_cache()
	local qvim_modules = {}
	for module, _ in pairs(package.loaded) do
		if module:match("qvim.core") or module:match("qvim.lsp") then
			package.loaded[module] = nil
			table.insert(qvim_modules, module)
		end
	end
	log.trace(
		fmt(
			"Cache invalidated for core modules: { %s }",
			table.concat(qvim_modules, ", ")
		)
	)
	require("qvim.lang.lsp.templates").generate_templates()
end

function M.run_post_update()
	log.debug("Starting post-update hook")

	if vim.fn.has("nvim-0.8") ~= 1 then
		local compat_tag = "1.1.4"
		vim.notify(
			"Please upgrade your Neovim base installation. Newer version of Lunarvim requires v0.7+",
			vim.log.levels.WARN
		)
		vim.wait(1000)
		local ret = reload("qvim.utils.git").switch_qvim_branch(compat_tag)
		if ret then
			vim.notify(
				"Reverted to the last known compatible version: " .. compat_tag,
				vim.log.levels.WARN
			)
		end
		return
	end

	M.reset_cache()

	log.debug("Syncing core plugins")
	plugin_loader.sync_core_plugins()

	if not in_headless then
		vim.schedule(function()
			if package.loaded["nvim-treesitter"] then
				vim.cmd([[ TSUpdateSync ]])
			end
			-- TODO: add a changelog
			vim.notify("Update complete", vim.log.levels.INFO)
		end)
	end
end

return M
