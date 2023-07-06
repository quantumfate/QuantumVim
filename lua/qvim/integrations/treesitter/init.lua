---The treesitter configuration file
local M = {}
if in_headless_mode() then
	return
end

local Log = require("qvim.log")
local utils = require("qvim.utils")

---Registers the global configuration scope for treesitter
function M:init()
	local treesitter = {
		active = true,
		on_config_done = nil,
		keymaps = {
			{
				name = "+Treesitter",
				binding_group = "T",
				bindings = {},
				options = {
					prefix = "<leader>",
				},
			},
		},
		options = {
			-- treesitter option configuration
			ensure_installed = { "comment", "markdown_inline", "regex", "dap_repl" },

			-- List of parsers to ignore installing (for "all")
			ignore_install = {},

			-- A directory to install the parsers into.
			-- By default parsers are installed to either the package dir, or the "site" dir.
			-- If a custom path is used (not nil) it must be added to the runtimepath.
			parser_install_dir = nil,

			-- Install parsers synchronously (only applied to `ensure_installed`)
			sync_install = false,

			-- Automatically install missing parsers when entering buffer
			auto_install = true,

			matchup = {
				enable = false, -- mandatory, false will disable the whole extension
				-- disable = { "c", "ruby" },  -- optional, list of language that will be disabled
			},
			highlight = {
				enable = true, -- false will disable the whole extension
				additional_vim_regex_highlighting = false,
				disable = function(lang, buf)
					if vim.tbl_contains({ "latex" }, lang) then
						return true
					end

					local status_ok, big_file_detected =
						pcall(vim.api.nvim_buf_get_var, buf, "bigfile_disable_treesitter")
					return status_ok and big_file_detected
				end,
			},

			indent = { enable = true, disable = { "yaml", "python" } },
			autotag = { enable = false },
		},
	}
	return treesitter
end

function M:config()
	-- treesitter config function to call additional configs
	local rainbow_ok, rainbow = pcall(require, "qvim.integrations.treesitter.rainbow")
	if rainbow_ok then
		rainbow:config()
	else
		Log:debug("Skipping rainbow for treesitter.")
	end

	qvim.integrations.treesitter.options = vim.tbl_deep_extend("keep", qvim.integrations.treesitter.options, {
		rainbow = qvim.integrations.treesitter.rainbow.options,
	})

	local climber_ok, climber = pcall(require, "qvim.integrations.treesitter.climber")
	if climber_ok then
		climber:config()
	else
		Log:debug("Skipping climber for treesitter.")
	end

	qvim.integrations.treesitter.options = vim.tbl_deep_extend("keep", qvim.integrations.treesitter.options, {
		climber = qvim.integrations.treesitter.climber.options,
	})

	-- TODO do something less scuffed
	qvim.integrations.treesitter.keymaps[1].bindings = vim.tbl_deep_extend(
		"keep",
		qvim.integrations.treesitter.keymaps[1].bindings,
		qvim.integrations.treesitter.climber.keymaps
	)

	local ctx_ok, ctx = pcall(require, "qvim.integrations.treesitter.context")
	if ctx_ok then
		ctx:config()
	else
		Log:debug("Skipping context-commentstring for treesitter.")
	end

	local ctx_comment_string_ok, ctx_comment_string =
		pcall(require, "qvim.integrations.treesitter.context-commentstring")
	if ctx_comment_string_ok then
		ctx_comment_string:config()
	else
		Log:debug("Skipping context-commentstring for treesitter.")
	end

	qvim.integrations.treesitter.options = vim.tbl_deep_extend("keep", qvim.integrations.treesitter.options, {
		context_commentstring = qvim.integrations.treesitter.context_commentstring.options,
	})
end

---The treesitter setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
	local path = utils.join_paths(get_qvim_rtp_dir(), "site", "pack", "lazy", "opt", "nvim-treesitter")
	vim.opt.rtp:prepend(path) -- treesitter needs to be before nvim's runtime in rtp
	if _G.in_headless_mode() then
		Log:debug("headless mode detected, skipping running setup for treesitter")
		return
	end
	local status_ok, treesitter = pcall(reload, "nvim-treesitter.configs")
	if not status_ok then
		Log:warn(string.format("The plugin '%s' could not be loaded.", treesitter))
		return
	end
	local repl_status_ok, repl_highlights = pcall(reload, "nvim-dap-repl-highlights")
	if repl_status_ok then
		repl_highlights.setup()
	else
		Log:warn(string.format("The extension '%s' could not be loaded.", repl_highlights))
	end

	local ctx_ok, ctx = pcall(require, "qvim.integrations.treesitter.context")
	if ctx_ok then
		ctx:setup()
	else
		Log:debug("Skipping context-commentstring for treesitter.")
	end

	local _treesitter = qvim.integrations.treesitter
	treesitter.setup(_treesitter.options)

	if _treesitter.on_config_done then
		_treesitter.on_config_done()
	end
	-- handle deprecated API, https://github.com/windwp/nvim-autopairs/pull/324
	local ts_utils = require("nvim-treesitter.ts_utils")
	ts_utils.is_in_node_range = vim.treesitter.is_in_node_range
	ts_utils.get_node_range = vim.treesitter.get_node_range
end

return M
