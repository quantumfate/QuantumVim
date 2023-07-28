local telescope_util = {}

local modules = require("qvim.utils.modules")

local builtin = modules.require_on_index("telescope.builtin")
local _ = modules.require_on_index("telescope.finders")
local _ = modules.require_on_index("telescope.pickers")
local _ = modules.require_on_index("telescope.sorters")
local themes = modules.require_on_index("telescope.themes")
local _ = modules.require_on_index("telescope.actions")
local _ = modules.require_on_index("telescope.previewers")
local _ = modules.require_on_index("telescope.make_entry")

---Hooks the extension `self` into telescope
---@param self AbstractExtension
function telescope_util.hook_extension(self)
	---@type telescope
	local telescope = getmetatable(self).__index
	telescope.options.extensions[self.main] = self.options
	table.insert(telescope.extensions_to_load, self.main)
end

function telescope_util.find_project_files(opts)
	opts = opts or {}

	local ok = pcall(builtin.git_files, opts)
	if not ok then
		builtin.find_files(opts)
	end
end

function telescope_util.find_qvim_files(opts)
	opts = opts or {}

	local theme_opts = themes.get_dropdown({
		sorting_strategy = "ascending",
		layout_strategy = "bottom_pane",
		prompt_prefix = ">> ",
		prompt_title = "QuantumVim Files",
		cwd = get_qvim_config_dir(),
		search_dirs = {
			get_qvim_data_dir(),
			get_qvim_state_dir(),
			get_qvim_cache_dir(),
		},
	})
	opts = vim.tbl_extend("keep", theme_opts, opts)
	builtin.live_grep(opts)
end

return telescope_util
