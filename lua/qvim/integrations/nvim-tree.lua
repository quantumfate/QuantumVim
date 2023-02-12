---The nvim-tree configuration file
local M = {}

local Log = require "qvim.integrations.log"

---Registers the global configuration scope for nvim-tree
M.config = function()
  local status_ok, nvim_tree_config = pcall(reload, "nvim-tree.config")
  if not status_ok then
    Log:warn("The plugin '%s' could not be loaded for configuration.", nvim_tree_config)
    return
  end

  local tree_cb = nvim_tree_config.nvim_tree_callback

  qvim.integrations.nvim_tree = {
      active = true,
      on_config_done = nil,
      glyphs = {
          default = "",
          symlink = "",
          git = {
              unstaged = "",
              staged = "s",
              unmerged = "",
              renamed = "➜",
              deleted = "",
              untracked = "u",
              ignored = "◌",
          },
          folder = {
              default = "",
              open = "",
              empty = "",
              empty_open = "",
              symlink = "",
          },
      },
      options = {
          -- nvim_tree option configuration
          disable_netrw = true,
          hijack_netrw = true,
          -- auto_close = true,
          open_on_tab = true,
          hijack_cursor = false,
          update_cwd = true,
          diagnostics = {
              enable = true,
              icons = {
                  hint = "",
                  info = "",
                  warning = "",
                  error = "",
              },
          },
          update_focused_file = {
              enable = true,
              update_cwd = true,
              ignore_list = {},
          },
          system_open = {
              cmd = nil,
              args = {},
          },
          filters = {
              dotfiles = false,
              custom = {},
          },
          git = {
              enable = true,
              ignore = true,
              timeout = 500,
          },
          view = {
              width = 30,
              side = "left",
              mappings = {
                  custom_only = false,
                  list = {
                      { key = { "l", "<cr>", "o" }, cb = tree_cb("edit") },
                      { key = "h",                  cb = tree_cb("close_node") },
                      { key = "v",                  cb = tree_cb("vsplit") },
                  },
              },
              number = false,
              relativenumber = false,
          },
          trash = {
              cmd = "trash",
              require_confirm = true,
          },
      },
  }
end

---The nvim-tree setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
M.setup = function()
  local status_ok, nvim_tree = pcall(reload, "nvim-tree")
  if not status_ok then
    Log:warn("The plugin '%s' could not be loaded.", nvim_tree)
    return
  end

  nvim_tree.icons = qvim.integrations.nvim_tree.glyphs
  nvim_tree.setup(qvim.integrations.nvim_tree.options)

  if qvim.integrations.nvim_tree.on_config_done then
    qvim.integrations.nvim_tree.on_config_done()
  end
end

return M
