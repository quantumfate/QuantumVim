local M = {}

local Log = require "qvim.log"
local shared_util = require "qvim.lang.utils"
local fmt = string.format
local lsp_utils = require "qvim.lang.lsp.utils"
local is_windows = vim.loop.os_uname().version:match "Windows"

local function resolve_mason_config(server_name)
    local found, mason_config =
        pcall(require, "mason-lspconfig.server_configurations." .. server_name)
    if not found then
        Log:debug(fmt("mason configuration not found for %s", server_name))
        return {}
    end
    local server_mapping = require "mason-lspconfig.mappings.server"
    local path = require "mason-core.path"
    local pkg_name = server_mapping.lspconfig_to_package[server_name]
    local install_dir = path.package_prefix(pkg_name)
    local conf = mason_config(install_dir)
    if is_windows and conf.cmd and conf.cmd[1] then
        local exepath = vim.fn.exepath(conf.cmd[1])
        if exepath ~= "" then
            conf.cmd[1] = exepath
        end
    end
    Log:debug(
        fmt(
            "resolved mason configuration for %s, got %s",
            server_name,
            vim.inspect(conf)
        )
    )
    return conf or {}
end

---Resolve the configuration for a server by merging with the default config
---@param server_name string
---@vararg any config table [optional]
---@return table
local function resolve_config(server_name, ...)
    local defaults = {
        on_attach = require("qvim.lang.lsp").common_on_attach,
        on_init = require("qvim.lang.lsp").common_on_init,
        on_exit = require("qvim.lang.lsp").common_on_exit,
        capabilities = require("qvim.lang.lsp").common_capabilities(),
    }

    local has_custom_provider, custom_config =
        pcall(require, "qvim.lang.lsp.providers." .. server_name)
    if has_custom_provider then
        Log:debug(
            "Using custom configuration for requested server: " .. server_name
        )
        defaults = vim.tbl_deep_extend("force", defaults, custom_config)
    end

    defaults = vim.tbl_deep_extend("force", defaults, ...)

    return defaults
end

-- manually start the server and don't wait for the usual filetype trigger from lspconfig
local function buf_try_add(server_name, bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    require("lspconfig")[server_name].manager.try_add_wrapper(bufnr)
end

-- check if the manager autocomd has already been configured since some servers can take a while to initialize
-- this helps guarding against a data-race condition where a server can get configured twice
-- which seems to occur only when attaching to single-files
local function client_is_configured(server_name, ft)
    ft = ft or vim.bo.filetype
    local active_autocmds =
        vim.api.nvim_get_autocmds { event = "FileType", pattern = ft }
    for _, result in ipairs(active_autocmds) do
        if
            result.desc ~= nil
            and result.desc:match("server " .. server_name .. " ")
        then
            Log:debug(string.format("[%q] is already configured", server_name))
            return true
        end
    end
    return false
end

local function launch_server(server_name, config)
    local command = config.cmd
        or (function()
            local default_config = require(
                "lspconfig.server_configurations." .. server_name
            ).default_config
            return default_config.cmd
        end)()
    -- some servers have dynamic commands defined with on_new_config
    if
        type(command) == "table"
        and type(command[1]) == "string"
        and vim.fn.executable(command[1]) ~= 1
    then
        Log:debug(
            string.format(
                "[%q] is either not installed, missing from PATH, or not executable.",
                server_name
            )
        )
        return
    end
    require("lspconfig")[server_name].setup(config)
    buf_try_add(server_name)
    Log:debug(fmt("Server started: %s", server_name))
end

---Setup a language server by providing a name
---@param server_name string name of the language server
---@param filetype string? the filetype where the setup was called
---@param user_config table? when available it will take predence over any default configurations
---@param skip_ft_ext boolean?
function M.setup(server_name, filetype, user_config, skip_ft_ext)
    vim.validate { name = { server_name, "string" } }
    user_config = user_config or {}

    if not skip_ft_ext and filetype then
        local status_ok, filetypes = pcall(require, "qvim.lang.lsp.filetypes")
        if status_ok then
            Log:debug(
                fmt(
                    "Called filetype extension. Server: '%s', FileType: '%s'",
                    server_name,
                    filetype
                )
            )
            if filetypes.setup(filetype) then
                return
            end

            local custom_lsp_settings = filetypes.custom_lsp_settings(filetype)
            if custom_lsp_settings then
                user_config = custom_lsp_settings
            end
        end
    end

    local package = lsp_utils.get_mason_package(server_name)

    if
        lsp_utils.is_client_active(server_name)
        or client_is_configured(server_name)
    then
        if server_name == "jdtls" then
            local config = resolve_config(server_name, user_config)
            launch_server(server_name, config)
        end
        return
    end

    if shared_util.is_package(package) then
        shared_util.try_install_and_setup_mason_package(
            ---@diagnostic disable-next-line: param-type-mismatch
            package,
            fmt("language server %s", server_name),
            function(_server_name, _user_config)
                local config = resolve_config(
                    _server_name,
                    resolve_mason_config(_server_name),
                    _user_config
                )
                launch_server(_server_name, config)
            end,
            { server_name, user_config }
        )
    else
        --TODO: install custom mason spec
        local config = resolve_config(server_name, user_config)
        launch_server(server_name, config)
    end
end

return M
