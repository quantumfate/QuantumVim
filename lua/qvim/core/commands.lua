local commands = {}
vim.cmd([[
  function! QuickFixToggle()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
      copen
    else
      cclose
    endif
  endfunction
]])

commands.defaults = {
    {
        name = "BufferKill",
        fn = function()
            require("qvim.core.plugins.bufferline").buf_kill("bd")
        end,
    },
    {
        name = "QvimToggleFormatOnSave",
        fn = function()
            require("qvim.core.autocmds").toggle_format_on_save()
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
    --[[     {
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
    }, ]]
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
        name = "QvimVersion",
        fn = function()
            print(require("qvim.utils.git").get_qvim_version())
        end,
    },
    {
        name = "QvimDebugLog",
        fn = function()
            vim.fn.execute("edit " .. require("qvim.log"):get_path("debug"))
        end,
    },
    {
        name = "QvimErrorLog",
        fn = function()
            vim.fn.execute("edit " .. require("qvim.log"):get_path("error"))
        end,
    },
    {
        name = "QvimInstallPlugins",
        fn = function()
            require("qvim.core.manager"):lazy_do_plugins("install")
        end
    },
    {
        name = "QvimUpdatePlugins",
        fn = function()
            require("qvim.core.manager"):lazy_do_plugins("update")
        end
    },
    {
        name = "QvimCleanPlugins",
        fn = function()
            require("qvim.core.manager"):lazy_do_plugins("clean")
        end
    },
    {
        name = "QvimSyncPlugins",
        fn = function()
            require("qvim.core.manager"):lazy_do_plugins("sync")
        end
    }
}

---Load commands
---@param collection table|nil commands or default commands when nil
function commands.load(collection)
    collection = collection or commands.defaults
    local common_opts = { force = true }
    for _, cmd in pairs(collection) do
        local opts = vim.tbl_deep_extend("force", common_opts, cmd.opts or {})
        vim.api.nvim_create_user_command(cmd.name, cmd.fn, opts)
    end
end

return commands
