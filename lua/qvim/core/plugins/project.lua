---The project configuration file
local M = {}

local Log = require "qvim.log"

---Registers the global configuration scope for project
function M:init()
    local project = {
        active = true,
        on_config_done = nil,
        keymaps = {},
        options = {
            -- project option configuration
            ---@usage set to true to disable setting the current-woriking directory
            --- Manual mode doesn't automatically change your root directory, so you have
            --- the option to manually do so using `:ProjectRoot` command.
            manual_mode = false,

            ---@usage Methods of detecting the root directory
            --- Allowed values: **"lsp"** uses the native neovim lsp
            --- **"pattern"** uses vim-rooter like glob pattern matching. Here
            --- order matters: if one is not detected, the other is used as fallback. You
            --- can also delete or rearangne the detection methods.
            -- detection_methods = { "lsp", "pattern" }, -- NOTE: lsp detection will get annoying with multiple langs in one project
            detection_methods = { "pattern" },

            -- All the patterns used to detect root dir, when **"pattern"** is in
            -- detection_methods
            patterns = {
                ".git",
                "_darcs",
                ".hg",
                ".bzr",
                ".svn",
                "Makefile",
                "package.json",
                "pom.xml",
            },

            -- Table of lsp clients to ignore by name
            -- eg: { "efm", ... }
            ignore_lsp = {},

            -- Don't calculate root dir on specific directories
            -- Ex: { "~/.cargo/*", ... }
            exclude_dirs = {},

            -- Show hidden files in telescope
            show_hidden = false,

            -- When set to false, you will get a message when project.nvim changes your
            -- directory.
            silent_chdir = true,

            -- What scope to change the directory, valid options are
            -- * global (default)
            -- * tab
            -- * win
            scope_chdir = "global",

            ---@type string
            ---@usage path to store the project history for use in telescope
            datapath = get_cache_dir(),
        },
    }
    return project
end

---The project setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
    if in_headless_mode() then
        return
    end
    local status_ok, project = pcall(reload, "project_nvim")
    if not status_ok then
        Log:warn(string.format("The plugin '%s' could not be loaded.", project))
        return
    end

    local _project = qvim.integrations.project
    project.setup(_project.options)

    if _project.on_config_done then
        _project.on_config_done()
    end
end

return M
