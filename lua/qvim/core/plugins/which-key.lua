---@class which-key : core_meta_plugin
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: which-key, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: which-key)|nil overwrite the setup function in core_base
---@field on_setup_done fun(self: which-key, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local which_key = {
  enabled = true,
  name = nil,
  options = {
    plugins = {
      marks = true,       -- shows a list of your marks on ' and `
      registers = true,   -- shows your registers on " in NORMAL or <C-r> in INSERT mode
      spelling = {
        enabled = true,   -- enabling this will show WhichKey when pressing z= to select spelling suggestions
        suggestions = 20, -- how many suggestions should be shown in the list?
      },
      -- the presets plugin, adds help for a bunch of default keybindings in Neovim
      -- No actual key bindings are created
      presets = {
        operators = false,    -- adds help for operators like d, y, ... and registers them for motion / text object completion
        motions = false,      -- adds help for motions
        text_objects = false, -- help for text objects triggered after entering an operator
        windows = true,       -- default bindings on <c-w>
        nav = true,           -- misc bindings to work with windows
        z = true,             -- bindings for folds, spelling and others prefixed with z
        g = true,             -- bindings for prefixed with g
      },
    },
    -- add operators that will trigger motion and text object completion
    -- to enable all native operators, set the preset / operators plugin above
    -- operators = { gc = "Comments" },
    key_labels = {
      -- override the label used to display some keys. It doesn't effect WK in any other way.
      -- For example:
      -- ["<space>"] = "SPC",
      -- ["<cr>"] = "RET",
      -- ["<tab>"] = "TAB",
    },
    icons = {
      breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
      separator = "➜", -- symbol used between a key and it's label
      group = "+", -- symbol prepended to a group
    },
    popup_mappings = {
      scroll_down = "<c-d>", -- binding to scroll down inside the popup
      scroll_up = "<c-u>",   -- binding to scroll up inside the popup
    },
    window = {
      border = "none",          -- none, single, double, shadow
      position = "bottom",      -- bottom, top
      margin = { 1, 0, 1, 0 },  -- extra window margin [top, right, bottom, left]
      padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
      winblend = 0,
    },
    layout = {
      height = { min = 4, max = 50 },                                             -- min and max height of the columns
      width = { min = 20, max = 50 },                                             -- min and max width of the columns
      spacing = 3,                                                                -- spacing between columns
      align = "left",                                                             -- align columns left, center or right
    },
    ignore_missing = false,                                                       -- enable this to hide mappings for which you didn't specify a label
    hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
    show_help = true,                                                             -- show help message on the command line when the popup is visible
    triggers = "auto",                                                            -- automatically setup triggers
    -- triggers = {"<leader>"} -- or specify a list manually
    triggers_blacklist = {
      -- list of mode / prefixes that should never be hooked by WhichKey
      -- this is mostly relevant for key maps that start with a native binding
      -- most people should not need to change this
      i = { "j", "k" },
      v = { "j", "k" },
    },
  },
  keymaps = {
    mappings = {
      ["<leader>"] = {
        [";"] = { "<cmd>Alpha<CR>", "Dashboard" },
        ["w"] = { "<cmd>w!<CR>", "Save" },
        ["q"] = { "<cmd>confirm q<CR>", "Quit" },
        ["/"] = { "<Plug>(comment_toggle_linewise_current)", "Comment toggle current line" },
        ["c"] = { "<cmd>BufferKill<CR>", "Close Buffer" },
        ["f"] = {
          function()
            require("lvim.core.telescope.custom-finders").find_project_files { previewer = false }
          end,
          "Find File",
        },
        ["h"] = { "<cmd>nohlsearch<CR>", "No Highlight" },
        ["e"] = { "<cmd>NvimTreeToggle<CR>", "Explorer" },
      },
      b = {
        name = "Buffers",
        j = { "<cmd>BufferLinePick<cr>", "Jump" },
        f = { "<cmd>Telescope buffers previewer=false<cr>", "Find" },
        b = { "<cmd>BufferLineCyclePrev<cr>", "Previous" },
        n = { "<cmd>BufferLineCycleNext<cr>", "Next" },
        W = { "<cmd>noautocmd w<cr>", "Save without formatting (noautocmd)" },
        -- w = { "<cmd>BufferWipeout<cr>", "Wipeout" }, -- TODO: implement this for bufferline
        e = {
          "<cmd>BufferLinePickClose<cr>",
          "Pick which buffer to close",
        },
        h = { "<cmd>BufferLineCloseLeft<cr>", "Close all to the left" },
        l = {
          "<cmd>BufferLineCloseRight<cr>",
          "Close all to the right",
        },
        D = {
          "<cmd>BufferLineSortByDirectory<cr>",
          "Sort by directory",
        },
        L = {
          "<cmd>BufferLineSortByExtension<cr>",
          "Sort by language",
        },
      },
    }

  },
  main = "which-key",
  on_setup_start = nil,
  setup = nil,
  on_setup_done = function(self)
    local wk = require("which-key")
    local dvorak_defaults = {

      insert_mode = {
        -- navigation
        ["<A-n>"] = { "<Esc>:m .+1<CR>==gi", "Move current line up" },
        ["<A-t>"] = { "<Esc>:m .-2<CR>==gi", "Move current line down" },
        ["<A-Up>"] = { "<C-\\><C-N><C-w>k", "Move up" },
        ["<A-Down>"] = { "<C-\\><C-N><C-w>j", "Move down" },
        ["<A-Left>"] = { "<C-\\><C-N><C-w>h", "Move left" },
        ["<A-Right>"] = { "<C-\\><C-N><C-w>l", "Move right" },
      },
      normal_mode = {
        -- Better window movement
        ["<C-h>"] = { "<C-w>h", "Go to left window" },
        ["<C-t>"] = { "<C-w>j", "Go to lower window" },
        ["<C-n>"] = { "<C-w>k", "Go to upper window" },
        ["<C-s>"] = { "<C-w>l", "Go to right window" },
        -- Resize with arrows
        ["<C-Up>"] = { ":resize -2<CR>", "Decrease window size horizontally" },
        ["<C-Down>"] = { ":resize +2<CR>", "Increase window size horizontally" },
        ["<C-Left>"] = { ":vertical resize -2<CR>", "Decrease window size vertically" },
        ["<C-Right>"] = { ":vertical resize +2<CR>", "Increase window size vertically" },
        -- Move current line / block with Alt-j/k a la vscode.
        ["<A-n>"] = { ":m .+1<CR>==", "Move current line up" },
        ["<A-t>"] = { ":m .-2<CR>==", "Move current line down" },
        ["]q"] = { ":cnext<CR>", "Fix next error" },
        ["[q"] = { ":cprev<CR>", "Fix previous error" },
        -- Navigate buffers
        ["<C-j>"] = { ":bnext<CR>", "Navigate to right buffer" },
        ["<C-k>"] = { ":bprev<CR>", "Navigate to left buffer" },
      },
      term_mode = {
        -- Terminal window navigation
        ["<C-h>"] = { "<C-\\><C-N><C-w>h", "Go to left terminal" },
        ["<C-t>"] = { "<C-\\><C-N><C-w>j", "Go to lower terminal" },
        ["<C-n>"] = { "<C-\\><C-N><C-w>k", "Go to upper terminal" },
        ["<C-s>"] = { "<C-\\><C-N><C-w>l", "Go to right terminal" },
      },
      visual_mode = {
        -- Better indenting
        ["<"] = { "<gv", "Indent right" },
        [">"] = { ">gv", "Indent left" },
        -- ["p"] = '"0p',
        -- ["P"] = '"0P',
      },
      visual_block_mode = {
        -- Move current line / block with Alt-j/k ala vscode.
        ["<A-t>"] = { ":m '>+1<CR>gv-gv", "Move current line down" },
        ["<A-n>"] = { ":m '<-2<CR>gv-gv", "Move current line up" },
      },
      command_mode = {
        -- navigate tab completion with <c-j> and <c-k>
        -- runs conditionally
        ["<C-t>"] = {
          'pumvisible() ? "\\<C-n>" : "\\<C-j>"',
          "Navigate tab completion down",
          expr = true,
          noremap = true,
        },
        ["<C-n>"] = {
          'pumvisible() ? "\\<C-p>" : "\\<C-k>"',
          "Navigate tab completion up",
          expr = true,
          noremap = true,
        },
      },
    }

    for _, value in pairs(dvorak_defaults) do
      wk.register(value)
    end
    require("qvim.core.util").register_keymaps(self)
  end,
  url = "https://github.com/folke/which-key.nvim",
}

which_key.__index = which_key

return which_key
