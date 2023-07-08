---@class FileType.python
local python = {}

function python.setup()
	local mason_path = vim.fn.glob(vim.fn.stdpath("data") .. "/mason/")
	pcall(function()
		require("dap-python").setup(mason_path .. "packages/debugpy/venv/bin/python")
	end)
end

return python
