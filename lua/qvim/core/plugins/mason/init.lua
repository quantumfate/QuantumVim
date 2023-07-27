local log = require("qvim.log")

---@class mason : core_meta_parent
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: mason, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: mason)|nil overwrite the setup function in core_base
---@field on_setup_done fun(self: mason, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
---@field bootstrap fun()
local mason = {
  enabled = true,
  name = nil,
  options = {
    ui = {
      check_outdated_packages_on_open = true,
      width = 0.8,
      height = 0.9,
      border = "rounded",
      keymaps = {
        toggle_package_expand = "<CR>",
        install_package = "i",
        update_package = "u",
        check_package_version = "c",
        update_all_packages = "U",
        check_outdated_packages = "C",
        uninstall_package = "X",
        cancel_installation = "<C-c>",
        apply_language_filter = "<C-f>",
      },
    },

    icons = {
      package_installed = "◍",
      package_pending = "◍",
      package_uninstalled = "◍",
    },

    -- NOTE: should be available in $PATH
    install_root_dir = join_paths(get_qvim_data_dir(), "mason"),

    -- NOTE: already handled in the bootstrap stage
    PATH = "skip",

    pip = {
      upgrade_pip = false,
      -- These args will be added to `pip install` calls. Note that setting extra args might impact intended behavior
      -- and is not recommended.
      --
      -- Example: { "--proxy", "https://proxyserver" }
      install_args = {},
    },

    -- Controls to which degree logs are written to the log file. It's useful to set this to vim.log.levels.DEBUG when
    -- debugging issues with package installations.
    log_level = vim.log.levels.INFO,

    -- Limit for the maximum amount of packages to be installed at the same time. Once this limit is reached, any further
    -- packages that are requested to be installed will be put in a queue.
    max_concurrent_installers = 4,

    -- [Advanced setting]
    -- The registries to source packages from. Accepts multiple entries. Should a package with the same name exist in
    -- multiple registries, the registry listed first will be used.
    registries = {
      "lua:mason-registry.index",
      "github:mason-org/mason-registry",
    },

    -- The provider implementations to use for resolving supplementary package metadata (e.g., all available versions).
    -- Accepts multiple entries, where later entries will be used as fallback should prior providers fail.
    providers = {
      "mason.providers.registry-api",
      "mason.providers.client",
    },

    github = {
      -- The template URL to use when downloading assets from GitHub.
      -- The placeholders are the following (in order):
      -- 1. The repository (e.g. "rust-lang/rust-analyzer")
      -- 2. The release version (e.g. "v0.3.0")
      -- 3. The asset name (e.g. "rust-analyzer-v0.3.0-x86_64-unknown-linux-gnu.tar.gz")
      download_url_template = "https://github.com/%s/releases/download/%s/%s",
    },

    on_config_done = nil,
  },
  keymaps = {},
  main = "mason",
  on_setup_start = nil,
  ---@param self mason
  setup = function(self)
    require("qvim.core.plugins.mason.util").add_to_path(self.options.PATH == "append")
    require("qvim.core.util").call_super_setup(self)
  end,
  on_setup_done = nil,
  url = "https://github.com/williamboman/mason.nvim",
}

mason.bootstrap = require("qvim.core.plugins.mason.util").bootstrap

mason.__index = mason

return mason
