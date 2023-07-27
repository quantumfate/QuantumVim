---@class project : core_meta_plugin
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: project, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: project)|nil overwrite the setup function in core_base
---@field on_setup_done fun(self: project, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local project = {
  enabled = true,
  name = nil,
  options = {
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
    patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "pom.xml" },

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
    datapath = get_qvim_cache_dir(),
  },
  keymaps = {},
  main = "project_nvim",
  on_setup_start = nil,
  setup = nil,
  on_setup_done = nil,
  url = "https://github.com/ahmedkhalf/project.nvim",
}

project.__index = project

return project
