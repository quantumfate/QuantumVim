---The vimtex configuration file
local M = {}

local Log = require("qvim.log")

---Registers the global configuration scope for vimtex
function M:init()
	local vimtex = {
		active = true,
		on_config_done = nil,
		keymaps = {},
		options = {
			-- vimtex option configuration
			tex_flavor = "latex",
			view_method = "zathura",
			quickfix_mode = 0,
			tex_conceal = "abdmgs",
			indentLine_setConceal = 0,
			compiler_method = "latexrun",
		},
	}
	return vimtex
end

---The vimtex setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
	if in_headless_mode() then
		return
	end
	local status_ok, vimtex = pcall(reload, "vimtex")
	if not status_ok then
		Log:warn(string.format("The plugin '%s' could not be loaded.", vimtex))
		return
	end

	vim.cmd([[
    " This is necessary for VimTeX to load properly. The "indent" is optional.
    " Note that most plugin managers will do this automatically.
    filetype plugin indent on

    " This enables Vim's and neovim's syntax-related features. Without this, some
    " VimTeX features will not work (see ":help vimtex-requirements" for more
    " info).
    syntax enable
  ]])

	local _vimtex = qvim.integrations.vimtex
	vim.g.tex_flavor = _vimtex.options.tex_flavor
	vim.g.vimtex_view_method = _vimtex.options.view_method
	vim.g.vimtex_quickfix_mode = _vimtex.options.quickfix_mode
	vim.g.tex_conceal = _vimtex.options.tex_conceal
	vim.g.indentLine_setConceal = _vimtex.options.indentLine_setConceal

	if _vimtex.on_config_done then
		_vimtex.on_config_done()
	end
end

return M
