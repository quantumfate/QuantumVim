local project_actions = require("telescope._extensions.project.actions")

---@class telescope-project : core_meta_ext, telescope
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps table|nil keymaps parsed to yikes.nvim
---@field main string|nil the string to use when the neovim plugin is required
---@field on_setup_start fun(self: telescope-project, instance: table|nil)|nil hook setup logic at the beginning of the setup call
---@field setup_ext fun(self: telescope-project)|nil overwrite the setup function in core_meta_ext
---@field on_setup_done fun(self: telescope-project, instance: table|nil)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local telescope_project = {
    enabled = true,
    name = nil,
    options = {
        project = {
            base_dirs = {
                { path = '~/.config', max_depth = 1 },
            },
            hidden_files = true, -- default: false
            theme = "dropdown",
            order_by = "asc",
            search_by = "title",
            sync_with_nvim_tree = true, -- default false
            -- default for on_project_selected = find project files
            on_project_selected = function(prompt_bufnr)
                -- Do anything you want in here. For example:
                project_actions.change_working_directory(prompt_bufnr, false)
                -- TODO: implement harpoon
                --require("harpoon.ui").nav_file(1)
            end
        }
    },
    keymaps = {},
    main = "project",
    on_setup_start = nil,
    ---@param self telescope-project<AbstractExtension>
    setup_ext = function(self)
        require("qvim.core.plugins.telescope.util").hook_extension(self)
    end,
    on_setup_done = nil,
    url = "https://github.com/nvim-telescope/telescope-project.nvim",
}

telescope_project.__index = telescope_project

return telescope_project
