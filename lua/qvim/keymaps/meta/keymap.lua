---@class keymap
local keymap = {}
local Log = require("qvim.integrations.log")
local default = require("qvim.keymaps.default")
local fn_t = require("qvim.utils.fn_t")
local fn = require("qvim.utils.fn")

--- The meta table that maps an index function to retrieve
--- the default keymap options. It implements an __eq meta method
--- to allow comparing of right hand side bindings.
keymap.opts_mt = {
    ---Merges default options with user defined options stored in the table
    ---@param t table the indexed table
    ---@param opt string
    ---@return table|nil
    __index = function(t, opt)
        if default.valid_keymap_opts[opt] then
            local opts = setmetatable(t, default.keymap_opts)
            return opts[opt]
        else
            Log:error(string.format("Invalid option '%s' for keymap.", opt))
            return nil
        end
    end,
    ---Set an value for a supported option and fill with defaults
    ---@param t table
    ---@param opt string
    ---@param setting function|boolean|string|integer|nil
    __newindex = function(t, opt, setting)
        if default.valid_keymap_opts[opt] and type(setting) == type(default.keymap_opts[opt]) or nil then
            local opts = setmetatable(t, default.keymap_opts)
            opts[opt] = setting
            t = opts
        else
            Log:error(string.format("Invalid option '%s' for keymap.", opt))
        end
    end,
    __eq = function(t1, t2)
        local function is_function(v) return type(v) == "function" end
        for k, v in pairs(t1) do
            if not is_function(v) and t2[k] ~= v then
                return false
            end
        end
        for k, v in pairs(t2) do
            if not is_function(v) and t1[k] ~= v then
                return false
            end
        end
        return true
    end,
}

keymap.opts_collection_mt = setmetatable({}, {
    __index = function(t)
        local opts_mt_bindings = setmetatable({}, keymap.opts_collection_mt)
        for _, value in ipairs(t) do
            if getmetatable(value) == keymap.opts_mt then
                table.insert(opts_mt_bindings, value)
            end
        end
        return opts_mt_bindings
    end,
    __newindex = function(t, idx, other)
        if getmetatable(other) == keymap.opts_mt then
            t[idx] = other
        end
    end
})

keymap.mt = setmetatable({}, {
    __index = function(t, lhs)
        if getmetatable(t) == keymap.opts_mt then
            return t[lhs]
        elseif getmetatable[t] == keymap.opts_collection_mt then
            return t.__index(t)
        end
    end,
    __newindex = function(t, lhs, other)
        ---Set user defined options and fill anything thats not defined with default values
        ---@param _other table
        ---@return table metatable the keymap.opts_mt metatable
        local function retrieve_opts_mt(_other)
            local opts = setmetatable({}, default.keymap_opts)
            for opt, value in pairs(_other) do
                if default.valid_keymap_opts[opt] then
                    opts[opt] = value
                end
            end
            return setmetatable(opts, { __index = keymap.opts_mt })
        end

        ---Set multiple user defined bindings
        ---@param _other table
        ---@return table metatable the keymap.opts_collection_mt metatable
        local function retrieve_opts_collection_mt(_other)
            local opts_collection = setmetatable({}, { __index = keymap.opts_collection_mt })
            for _, binding in pairs(_other) do
                table.insert(opts_collection, retrieve_opts_mt(binding))
            end
            return opts_collection
        end

        ---Returns a specific metatable
        ---@param _other table|any
        ---@return table|nil metatable keymap.opts_mt or keymap.opts_collection_mt or nil
        local function define_other_table(_other)
            if type(_other) == "table" and type(next(_other)) == "table" then
                return retrieve_opts_collection_mt(_other)
            elseif type(_other) == "table" then
                return retrieve_opts_mt(_other)
            end
            -- TODO: log eventually
            return nil
        end

        if type(other) == "table" then
            local post_t = define_other_table(other)
            if t[lhs] then
                -- TODO: merge simple table bindings and complex table bindings and vice verca
                table.insert(t[lhs], post_t)
            else
                t[lhs] = post_t
            end
        end
    end
})


return keymap
--    __eq = function(t1, t2)
--
--    end,
--    ---This meta method is called when the opts_mt is indexed
--    ---@param _ table not used
--    ---@param opt string the key corresponding to any of the supported default options
--    ---@return boolean|string|integer|nil
--
--    --__call = function(_, opt)
--    --    if default.valid_keymap_opts[opt] then
--    --        return default.keymap_opts[opt]
--    --    else
--    --        Log:error(string.format("Invalid option '%s' for keymap.", opt))
--    --    end
--    --end,
--    ---Ensures that at least the default options are stored in the table
--    ---end sets user defined values if they are supported
--    ---@param t table
--    ---@param lhs string the left hand side of a keymap
--    ---@param other table the keymap corresponding to the left hand side
--    __newindex = function(t, lhs, other)
--        local lhs_is_string = type(lhs) == "string" and not fn.isempty(lhs)
--        local other_is_table = type(other) == "table" and #other > 0
--        if lhs_is_string then
--            if other_is_table then
--                local opts_are_valid = true
--                local invalid_opts = ""
--                local valid_opts = {}
--                for opt, _ in pairs(other) do
--                    if not default.valid_keymap_opts[opt] then
--                        invalid_opts = invalid_opts .. opt .. ", "
--                        opts_are_valid = false
--                    else
--                        table.insert(valid_opts, opt)
--                    end
--                end
--                if opts_are_valid then
--                    local persistent_options = fn_t.rawget_debug(t, lhs, "keymap_opts") or {}
--                    local user_options = {}
--
--                    if #persistent_options > 0 then
--                        if persistent_options.unique then
--                            user_options = persistent_options
--                            Log:warn(string.format(
--                                "Attempted to override a unique keymap '%s'. Its corresponding options '%s' will be kept.",
--                                lhs,
--                                vim.inspect(persistent_options)))
--                        elseif other.unique then
--                            -- discard duplicated mapping
--                            Log:warn(string.format(
--                                "An existing non-unqiue keymap '%s' was overriden by the options: '%s'.", lhs,
--                                vim.inspect(other)))
--
--                            user_options = setmetatable(other, { __index = keymap.rhs_mt })
--                        else
--                            -- keep both mappings
--                            table.insert(user_options, persistent_options)
--                            table.insert(user_options, other)
--                        end
--                    else
--                        user_options = setmetatable(other, { __index = keymap.rhs_mt })
--                        Log:debug(string.format("A new keybinding from '%s' with the options '%' was detected.", lhs,
--                            vim.inspect(user_options)))
--                    end
--                    fn_t.rawset_debug(t, lhs, user_options,
--                        string.format("Setting keymap options: %s", vim.inspect(user_options)))
--                else
--                    Log:error(string.format("Invalid option '%s' for keymap.", invalid_opts:sub(1, -3)))
--                end
--            else
--                if not type(other) == "table" then
--                    Log:error(string.format(
--                        "Declaring keymap options must be done in a table but got '%s'.",
--                        type(other)))
--                elseif not #other > 0 then
--                    Log:error(string.format(
--                        "Empty table detected. No keymap options were set. Table: '%s'.",
--                        other))
--                end
--            end
--        else
--            if not type(lhs) == "string" then
--                Log:error(string.format("The left hand side of a keymap must be a string but is '%s'.", type(lhs)))
--            end
--            if fn.isempty(lhs) then
--                Log:error(string.format("The left hand side of a keymap is an empty string.", type(lhs)))
--            end
--        end
--    end
--
