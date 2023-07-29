---@class toggleterm : core_meta_plugin
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: toggleterm, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: toggleterm)|nil overwrite the setup function in core_base
---@field on_setup_done fun(self: toggleterm, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local toggleterm = {
	enabled = true,
	name = nil,
	options = {
		size = 20,
		open_mapping = [[<c-\>]],
		hide_numbers = true,
		shade_filetypes = {},
		shade_terminals = true,
		shading_factor = 2,
		start_in_insert = true,
		insert_mappings = true,
		persist_size = true,
		direction = "tab",
		close_on_exit = true,
		on_open = function(_)
			_G.set_terminal_keymaps()
		end,
		shell = vim.o.shell,
		float_opts = {
			border = "curved",
			winblend = 0,
			highlights = {
				border = "Normal",
				background = "Normal",
			},
		},
	},
	keymaps = {
		mappings = {
			t = {
				name = "Toggleterm",
				n = { "<cmd>lua _NODE_TOGGLE()<cr>", "Node" },
				u = { "<cmd>lua _NCDU_TOGGLE()<cr>", "NCDU" },
				t = { "<cmd>lua _HTOP_TOGGLE()<cr>", "Htop" },
				p = { "<cmd>lua _PYTHON_TOGGLE()<cr>", "Python" },
				f = { "<cmd>ToggleTerm direction=float<cr>", "Float" },
				h = {
					"<cmd>ToggleTerm size=10 direction=horizontal<cr>",
					"Horizontal",
				},
				v = {
					"<cmd>ToggleTerm size=80 direction=vertical<cr>",
					"Vertical",
				},
			},
		},
	},
	main = "toggleterm",
	on_setup_start = nil,
	setup = nil,
	on_setup_done = function(self, _)
		local Terminal = require("toggleterm.terminal").Terminal
		local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })

		function _G._LAZYGIT_TOGGLE()
			lazygit:toggle()
		end

		local node = Terminal:new({ cmd = "node", hidden = true })

		function _G._NODE_TOGGLE()
			node:toggle()
		end

		local ncdu = Terminal:new({ cmd = "ncdu", hidden = true })

		function _G._NCDU_TOGGLE()
			ncdu:toggle()
		end

		local htop = Terminal:new({ cmd = "htop", hidden = true })

		function _G._HTOP_TOGGLE()
			htop:toggle()
		end

		local python = Terminal:new({ cmd = "python", hidden = true })

		function _G._PYTHON_TOGGLE()
			python:toggle()
		end

		local module = require("qvim.utils.modules")
		local wk = module.require_on_index("which-key")
		function _G.set_terminal_keymaps()
			local opts = {
				noremap = true,
				buffer = vim.api.nvim_get_current_buf(),
				mode = "t",
			}

			wk.register({
				["<esc>"] = { "<C-\\><C-n>", "Exit Terminal" },
				["<C-h>"] = { "<C-\\><C-n><C-W>h", "Move Left" },
				["<C-t>"] = { "<C-\\><C-n><C-W>j", "Move Down" },
				["<C-n>"] = { "<C-\\><C-n><C-W>k", "Move Up" },
				["<C-s>"] = { "<C-\\><C-n><C-W>l", "Move Right" },
			}, opts)
		end

		wk.register(
			self.keymaps.mappings,
			{ noremap = true, prefix = "<leader>" }
		)
	end,
	url = "https://github.com/akinsho/toggleterm.nvim",
}

toggleterm.__index = toggleterm

return toggleterm
