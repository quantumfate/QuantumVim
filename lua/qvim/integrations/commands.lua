local M = {}

vim.cmd([[
  function! QuickFixToggle()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
      copen
    else
      cclose
    endif
  endfunction
]])

M.defaults = {
	{
		name = "BufferKill",
		fn = function()
			require("qvim.integrations.bufferline").buf_kill("bd")
		end,
	},
	{
		name = "qvimToggleFormatOnSave",
		fn = function()
			require("qvim.integrations.autocmds").toggle_format_on_save()
		end,
	},
	--{
	--  name = "qvimInfo",
	--  fn = function()
	--    require("qvim.core.info").toggle_popup(vim.bo.filetype)
	--  end,
	--},
	--{
	--  name = "qvimDocs",
	--  fn = function()
	--    local documentation_url = "https://www.lunarvim.org/docs/quick-start"
	--    if vim.fn.has "mac" == 1 or vim.fn.has "macunix" == 1 then
	--      vim.fn.execute("!open " .. documentation_url)
	--    elseif vim.fn.has "win32" == 1 or vim.fn.has "win64" == 1 then
	--      vim.fn.execute("!start " .. documentation_url)
	--    elseif vim.fn.has "unix" == 1 then
	--      vim.fn.execute("!xdg-open " .. documentation_url)
	--    else
	--      vim.notify "Opening docs in a browser is not supported on your OS"
	--    end
	--  end,
	--},
	{
		name = "qvimCacheReset",
		fn = function()
			require("qvim.utils.hooks").reset_cache()
		end,
	},
	{
		name = "qvimReload",
		fn = function()
			require("qvim.config"):reload()
		end,
	},
	{
		name = "qvimUpdate",
		fn = function()
			require("qvim.bootstrap"):update()
		end,
	},
	--{
	--  name = "qvimSyncCorePlugins",
	--  fn = function()
	--    require("qvim.integrations._loader.plugin-loader").sync_core_plugins()
	--  end,
	--},
	--{
	--  name = "qvimChangelog",
	--  fn = function()
	--    require("qvim.core.telescope.custom-finders").view_lunarvim_changelog()
	--  end,
	--},
	{
		name = "qvimVersion",
		fn = function()
			print(require("qvim.utils.git").get_qvim_version())
		end,
	},
	{
		name = "qvimOpenlog",
		fn = function()
			vim.fn.execute("edit " .. require("qvim.log"):get_path())
		end,
	},
}

function M.load(collection)
	local common_opts = { force = true }
	for _, cmd in pairs(collection) do
		local opts = vim.tbl_deep_extend("force", common_opts, cmd.opts or {})
		vim.api.nvim_create_user_command(cmd.name, cmd.fn, opts)
	end
end

return M
