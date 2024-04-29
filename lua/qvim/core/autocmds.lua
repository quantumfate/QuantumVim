local M = {}
local Log = require("qvim.log").qvim

--- Load the default set of autogroups and autocommands.
function M.load_defaults()
	if _G.in_headless_mode() then
		return
	end
	local definitions = {
		{
			"VimEnter * ",
			{
				group = "_general_settings",
				desc = "Disable terminal padding",
				callback = function()
					vim.fn.system(
						"kitty @ set-spacing padding=0 > /dev/null 2>&1"
					)
				end,
			},
		},
		{
			"VimLeave * ",
			{
				group = "_general_settings",
				desc = "Disable terminal padding",
				callback = function()
					vim.fn.system(
						"kitty @ set-spacing padding=5 > /dev/null 2>&1"
					)
				end,
			},
		},
		{
			{
				"WinScrolled", -- or WinResized on NVIM-v0.9 and higher
				"BufWinEnter",
				"CursorHold",
				"InsertLeave",

				-- include this if you have set `show_modified` to `true`
				"BufModifiedSet",
			},
			{
				group = vim.api.nvim_create_augroup("barbecue.updater", {}),
				callback = function()
					require("barbecue.ui").update()
				end,
			},
		},
		{
			"InsertEnter",
			{
				group = "_general_settings",
				desc = "Close nvim tree when entering insert mode",
				callback = function()
					require("nvim-tree.api").tree.close()
				end,
			},
		},
		{
			"TextYankPost",
			{
				group = "_general_settings",
				pattern = "*",
				desc = "Highlight text on yank",
				callback = function()
					vim.highlight.on_yank({ higroup = "Search", timeout = 100 })
				end,
			},
		},
		{
			"FileType",
			{
				group = "_hide_dap_repl",
				pattern = "dap-repl",
				command = "set nobuflisted",
			},
		},
		{
			"FileType",
			{
				group = "_filetype_settings",
				pattern = { "lua" },
				desc = "fix gf functionality inside .lua files",
				callback = function()
					---@diagnostic disable: assign-type-mismatch
					-- credit: https://github.com/sam4llis/nvim-lua-gf
					vim.opt_local.include =
						[[\v<((do|load)file|require|reload)[^''"]*[''"]\zs[^''"]+]]
					vim.opt_local.includeexpr =
						"substitute(v:fname,'\\.','/','g')"
					vim.opt_local.suffixesadd:prepend(".lua")
					vim.opt_local.suffixesadd:prepend("init.lua")

					for _, path in pairs(vim.api.nvim_list_runtime_paths()) do
						vim.opt_local.path:append(path .. "/lua")
					end
				end,
			},
		},
		{
			"FileType",
			{
				group = "_buffer_mappings",
				pattern = {
					"qf",
					"help",
					"man",
					"floaterm",
					"lspinfo",
					"lir",
					"lsp-installer",
					"null-ls-info",
					"tsplayground",
					"DressingSelect",
					"Jaq",
				},
				callback = function()
					vim.keymap.set(
						"n",
						"q",
						"<cmd>close<cr>",
						{ buffer = true }
					)
					vim.opt_local.buflisted = false
				end,
			},
		},
		{
			"VimResized",
			{
				group = "_auto_resize",
				pattern = "*",
				command = "tabdo wincmd =",
			},
		},
		{
			"FileType",
			{
				group = "_filetype_settings",
				pattern = "alpha",
				callback = function()
					vim.cmd([[
                        set nobuflisted
                    ]])
				end,
			},
		},
		{
			"FileType",
			{
				group = "_filetype_settings",
				pattern = "lir",
				callback = function()
					vim.opt_local.number = false
					vim.opt_local.relativenumber = false
				end,
			},
		},
		{
			"FileType",
			{
				callback = function()
					-- hide buffer line in alpha
					vim.cmd([[
            autocmd User AlphaReady set showtabline=0 | autocmd BufUnload <buffer> set showtabline=2
          ]])
				end,
			},
		},
		{
			"ColorScheme",
			{
				group = "_qvim_colorscheme",
				callback = function()
					if qvim.plugins.nvim_navic.enabled then
						require("qvim.core.plugins.nvim-navic").get_winbar()
					end
					---@type colors
					local colors =
						require("catppuccin.palettes").get_palette("mocha")

					vim.api.nvim_set_hl(0, "QvNoiceError", { fg = colors.pink })

					vim.api.nvim_set_hl(
						0,
						"CmpItemKindCopilot",
						{ fg = colors.green }
					)
					vim.api.nvim_set_hl(
						0,
						"CmpItemKindTabnine",
						{ fg = colors.mauve }
					)
					vim.api.nvim_set_hl(
						0,
						"CmpItemKindCrate",
						{ fg = colors.peach }
					)
					vim.api.nvim_set_hl(
						0,
						"CmpItemKindEmoji",
						{ fg = colors.yellow }
					)
					vim.api.nvim_set_hl(0, "QVLLCopilot", { fg = colors.green })
					vim.api.nvim_set_hl(
						0,
						"QVLLGitIcon",
						{ fg = colors.rosewater }
					)
					vim.api.nvim_set_hl(
						0,
						"QVLLBranchName",
						{ fg = colors.rosewater }
					)

					vim.api.nvim_set_hl(
						0,
						"QVLLComponentSeparatorGreyBg",
						{ fg = colors.pink, bg = colors.surface0 }
					)
					vim.api.nvim_set_hl(
						0,
						"QVLLComponentSeparatorGreyFgLighterGreyBg",
						{ fg = colors.surface0, bg = colors.surface1 }
					)
					vim.api.nvim_set_hl(
						0,
						"QVLLItemActiveGreyBg",
						{ fg = colors.teal, bg = colors.surface0 }
					)
					vim.api.nvim_set_hl(
						0,
						"QVLLItemInactiveGreyBg",
						{ fg = colors.red, bg = colors.surface0 }
					)
					vim.api.nvim_set_hl(
						0,
						"QVLLTextOneGreyBg",
						{ fg = colors.rosewater, bg = colors.surface0 }
					)
					vim.api.nvim_set_hl(
						0,
						"QVLLTextTwoGreyBg",
						{ fg = colors.pink, bg = colors.surface0 }
					)
					vim.api.nvim_set_hl(
						0,
						"QVLLTextThreeGreyBg",
						{ fg = colors.peach, bg = colors.surface0 }
					)
					vim.api.nvim_set_hl(
						0,
						"QVLLTextFourGreyBg",
						{ fg = colors.sky, bg = colors.surface0 }
					)
					vim.api.nvim_set_hl(
						0,
						"QVLLTextFiveGreyBg",
						{ fg = colors.mauve, bg = colors.surface0 }
					)

					vim.api.nvim_set_hl(
						0,
						"QVLLComponentSeparatorGreyLighterBg",
						{ fg = colors.pink, bg = colors.surface1 }
					)
					vim.api.nvim_set_hl(
						0,
						"QVLLComponentSeparatorGreyLighterFgGreyBg",
						{ fg = colors.surface1, bg = colors.surface0 }
					)
					vim.api.nvim_set_hl(
						0,
						"QVLLItemActiveGreyLighterBg",
						{ fg = colors.teal, bg = colors.surface1 }
					)
					vim.api.nvim_set_hl(
						0,
						"QVLLItemInactiveGreyLighterBg",
						{ fg = colors.red, bg = colors.surface1 }
					)
					vim.api.nvim_set_hl(
						0,
						"QVLLTextOneGreyLighterBg",
						{ fg = colors.rosewater, bg = colors.surface1 }
					)
					vim.api.nvim_set_hl(
						0,
						"QVLLTextTwoGreyLighterBg",
						{ fg = colors.pink, bg = colors.surface1 }
					)
					vim.api.nvim_set_hl(
						0,
						"QVLLTextThreeGreyLighterBg",
						{ fg = colors.flamingo, bg = colors.surface1 }
					)
					vim.api.nvim_set_hl(
						0,
						"QVLLTextFourGreyLighterBg",
						{ fg = colors.lavender, bg = colors.surface1 }
					)
					vim.api.nvim_set_hl(
						0,
						"QVLLTextFiveGreyLighterBg",
						{ fg = colors.text, bg = colors.surface1 }
					)
				end,
			},
		},
		{ -- taken from AstroNvim
			"BufEnter",
			{
				group = "_dir_opened",
				nested = true,
				callback = function(args)
					local bufname = vim.api.nvim_buf_get_name(args.buf)
					if require("qvim.utils").is_directory(bufname) then
						vim.api.nvim_del_augroup_by_name("_dir_opened")
						vim.cmd("do User DirOpened")
						vim.api.nvim_exec_autocmds(
							args.event,
							{ buffer = args.buf, data = args.data }
						)
					end
				end,
			},
		},
		{ -- taken from AstroNvim
			{ "BufRead", "BufWinEnter", "BufNewFile" },
			{
				group = "_file_opened",
				nested = true,
				callback = function(args)
					local buftype = vim.api.nvim_get_option_value(
						"buftype",
						{ buf = args.buf }
					)
					if
						not (vim.fn.expand("%") == "" or buftype == "nofile")
					then
						vim.api.nvim_del_augroup_by_name("_file_opened")
						vim.cmd("do User FileOpened")
						require("qvim.lang").setup()
					end
				end,
			},
		},
	}

	M.define_autocmds(definitions)
end

local get_format_on_save_opts = function()
	local defaults = require("qvim.config").format_on_save
	-- accept a basic boolean `lvim.format_on_save=true`
	if type(qvim.format_on_save) ~= "table" then
		return defaults
	end

	return {
		pattern = qvim.format_on_save.pattern or defaults.pattern,
		timeout = qvim.format_on_save.timeout or defaults.timeout,
	}
end

function M.enable_format_on_save()
	local opts = get_format_on_save_opts()
	vim.api.nvim_create_augroup("lsp_format_on_save", {})
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = "lsp_format_on_save",
		pattern = opts.pattern,
		callback = function()
			require("qvim.lang.lsp.utils").format({
				timeout_ms = opts.timeout,
				filter = opts.filter,
			})
		end,
	})
	Log.debug("enabled format-on-save")
end

function M.disable_format_on_save()
	M.clear_augroup("lsp_format_on_save")
	Log.debug("disabled format-on-save")
end

function M.configure_format_on_save()
	if type(qvim.format_on_save) == "table" and qvim.format_on_save.enabled then
		M.enable_format_on_save()
	elseif qvim.format_on_save == true then
		M.enable_format_on_save()
	else
		M.disable_format_on_save()
	end
end

function M.toggle_format_on_save()
	local exists, autocmds = pcall(vim.api.nvim_get_autocmds, {
		group = "lsp_format_on_save",
		event = "BufWritePre",
	})
	if not exists or #autocmds == 0 then
		M.enable_format_on_save()
	else
		M.disable_format_on_save()
	end
end

--[[ function M.enable_reload_config_on_save()
  -- autocmds require forward slashes (even on windows)
  local pattern = get_qvim_rtp_dir():gsub("\\", "/") .. "/*.lua"

  vim.api.nvim_create_augroup("qvim_reload_config_on_save", {})
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = "qvim_reload_config_on_save",
    pattern = pattern,
    desc = "Trigger QvimReload on saving config.lua",
    callback = function()
      require("lvim.config"):reload()
    end,
  })
end
 ]]
function M.enable_transparent_mode()
	vim.api.nvim_create_autocmd("ColorScheme", {
		pattern = "*",
		callback = function()
			local hl_groups = {
				"Normal",
				"SignColumn",
				"NormalNC",
				"TelescopeBorder",
				"NvimTreeNormal",
				"NvimTreeNormalNC",
				"EndOfBuffer",
				"MsgArea",
			}
			for _, name in ipairs(hl_groups) do
				vim.cmd(
					string.format("highlight %s ctermbg=none guibg=none", name)
				)
			end
		end,
	})
	vim.opt.fillchars = "eob: "
end

--- Clean autocommand in a group if it exists
--- This is safer than trying to delete the augroup itself
---@param name string the augroup name
function M.clear_augroup(name)
	-- defer the function in case the autocommand is still in-use
	Log.debug("request to clear autocmds  " .. name)
	vim.schedule(function()
		pcall(function()
			vim.api.nvim_clear_autocmds({ group = name })
		end)
	end)
end

--- Create autocommand groups based on the passed definitions
--- Also creates the augroup automatically if it doesn't exist
---@param definitions table contains a tuple of event, opts, see `:h nvim_create_autocmd`
function M.define_autocmds(definitions)
	for _, entry in ipairs(definitions) do
		local event = entry[1]
		local opts = entry[2]
		if type(opts.group) == "string" and opts.group ~= "" then
			local exists, _ =
				pcall(vim.api.nvim_get_autocmds, { group = opts.group })
			if not exists then
				vim.api.nvim_create_augroup(opts.group, {})
			end
		end
		vim.api.nvim_create_autocmd(event, opts)
	end
end

return M
