local M = {
}
local Log = require "qvim.integrations.log"

local util = require("qvim.utils")
local home_dir = os.getenv("HOME")
local virtualenvs_path = _G.join_paths(home_dir, ".virtualenvs")
local debugpy_path = _G.join_paths(virtualenvs_path, 'debugpy')


local fmt = string.format

---https://github.com/mfussenegger/nvim-dap-python

function M.adapt()
    Log:debug(fmt("Setting up debug adapter for python in '%s'.", virtualenvs_path))

    local is_dir_venv = util.is_directory(virtualenvs_path)

    if not is_dir_venv then
        local ok_mkir = os.execute("mkdir .virtualenvs")
        if ok_mkir then
            Log:debug(fmt("Successfully created the directory '%s' for debugpy.", virtualenvs_path))
        else
            Log:debug(fmt("Failed to create the directory '%s' for debugpy.", virtualenvs_path))
        end

        local is_dir_debugpy = util.is_directory(debugpy_path)
        if not is_dir_debugpy then
            local ok_debugpy = os.execute(
                "cd .virtualenvs && python -m venv debugpy && debugpy/bin/python -m pip install debugpy")

            if ok_debugpy then
                Log:debug(fmt("Successfully installed debugpy in '%s'.", debugpy_path))
            else
                Log:debug(fmt("Failed to install debugpy in '%s'.", debugpy_path))
            end
        end
    end
end

return M
