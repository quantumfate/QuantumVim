---@diagnostic disable
-- vim: ft=lua tw=80

stds.nvim = {
	globals = {
		"user",
		"reload",
		vim = { fields = { "g" } },
		"TERMINAL",
		"USER",
		"C",
		"Config",
		"WORKSPACE_PATH",
		"JAVA_LS_EXECUTABLE",
		"MUtils",
		"USER_CONFIG_PATH",
		"qvim",
		os = { fields = { "capture" } },
	},
	read_globals = {
		"jit",
		"os",
		"path_sep",
		"vim",
		"join_paths",
		"get_qvim_log_dir",
		"get_qvim_cache_dir",
		"get_qvim_state_dir",
		"get_qvim_config_dir",
		"get_qvim_data_dir",
		"get_qvim_rtp_dir",
		"get_qvim_base_dir",
		"get_qvim_pack_dir",
		"get_qvim_structlog_dir",
		"get_lazy_rtp_dir",
		"require_clean",
	},
}
std = "lua51+nvim"

files["tests/*_spec.lua"].std = "lua51+nvim+busted"
files["lua/qvim/impatient*"].ignore = { "121" }

-- Don't report unused self arguments of methods.
self = false

-- Rerun tests only if their modification time changed.
cache = true

ignore = {
	"631", -- max_line_length
	"212/_.*", -- unused argument, for vars with "_" prefix
}
