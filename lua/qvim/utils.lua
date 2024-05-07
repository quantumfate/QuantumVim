local M = {}
local uv = vim.loop

local initial_log_call = { max_parents = 5, stack_level = 6 }
---Crates a loppipeline for structured logging with a `stack_level=6` for each channel because it takes exactly
---`6` stack calls from the initial log call to the internal log call writing to the target sink.
---@param log StructlogImpl The logger instance
---@param structlog table The structlog instace
---@param name string Name of the pipeline
---@return table t
function M.create_log_pipeline(log, structlog, name)
	return {
		{
			level = structlog.level.INFO,
			processors = {
				structlog.processors.StackWriter(
					{ "line", "file" },
					initial_log_call
				),
				structlog.processors.Timestamper("%H:%M:%S"),
			},
			formatter = structlog.formatters.FormatColorizer( --
				"%s [%s] %s: %-30s",
				{ "timestamp", "level", "logger_name", "msg" },
				{
					level = structlog.formatters.FormatColorizer.color_level(),
				}
			),
			sink = structlog.sinks.Console(),
		},
		{
			level = structlog.level.ERROR,
			processors = {
				structlog.processors.StackWriter(
					{ "line", "file" },
					initial_log_call
				),
				structlog.processors.Timestamper("%H:%M:%S"),
			},
			formatter = structlog.formatters.Format( --
				"%s [%s] %s: %-30s",
				{ "timestamp", "level", "logger_name", "msg" }
			),
			sink = structlog.sinks.File(log.get_path("error", name)),
		},
		{
			level = structlog.level.DEBUG,
			processors = {
				structlog.processors.StackWriter(
					{ "line", "file" },
					initial_log_call
				),
				structlog.processors.Timestamper("%H:%M:%S"),
			},
			formatter = structlog.formatters.Format( --
				"%s [%s] %s: %-30s",
				{ "timestamp", "level", "logger_name", "msg" }
			),
			sink = structlog.sinks.File(log.get_path("debug", name)),
		},
		{
			level = structlog.level.TRACE,
			processors = {
				structlog.processors.StackWriter(
					{ "line", "file" },
					initial_log_call
				),
				structlog.processors.Timestamper("%H:%M:%S"),
			},
			formatter = structlog.formatters.Format( --
				"%s [%s] %s: %-30s",
				{ "timestamp", "level", "logger_name", "msg" }
			),
			sink = structlog.sinks.File(log.get_path("trace", name)),
		},
		{
			level = structlog.level.WARN,
			processors = {},
			formatter = structlog.formatters.Format(
				"%s",
				{ "msg" },
				{ blacklist = { "level", "logger_name" } }
			),
			sink = structlog.sinks.NvimNotify(),
		},
	}
end

---Recursively print a structure pretty formatted with a separator
---@param structure any the structure to be recursed
---@param limit any the maximum depth for the recursion
---@param separator any the string to pretty format the structure
---@return integer|unknown limit limit - 1
function M.r_inspect_settings(structure, limit, separator)
	limit = limit or 100 -- default item limit
	separator = separator or "." -- indent string
	if limit < 1 then
		print("ERROR: Item limit reached.")
		return limit - 1
	end
	if structure == nil then
		io.write("-- O", separator:sub(2), " = nil\n")
		return limit - 1
	end
	local ts = type(structure)

	if ts == "table" then
		for k, v in pairs(structure) do
			-- replace non alpha keys with ["key"]
			if tostring(k):match("[^%a_]") then
				k = '["' .. tostring(k) .. '"]'
			end
			limit =
				M.r_inspect_settings(v, limit, separator .. "." .. tostring(k))
			if limit < 0 then
				break
			end
		end
		return limit
	end

	if ts == "string" then
		-- escape sequences
		structure = string.format("%q", structure)
	end
	separator = separator:gsub("%.%[", "%[")
	if type(structure) == "function" then
		-- don't print functions
		io.write("-- qvim", separator:sub(2), " = function ()\n")
	else
		io.write("qvim", separator:sub(2), " = ", tostring(structure), "\n")
	end
	return limit - 1
end

--- Returns a table with the default values that are missing.
--- either parameter can be empty.
--@param config (table) table containing entries that take priority over defaults
--@param default_config (table) table contatining default values if found
function M.apply_defaults(config, default_config)
	config = config or {}
	default_config = default_config or {}
	local new_config = vim.tbl_deep_extend("keep", vim.empty_dict(), config)
	new_config = vim.tbl_deep_extend("keep", new_config, default_config)
	return new_config
end

--- Checks whether a given path exists and is a file.
--@param path (string) path to check
--@returns (bool)
function M.is_file(path)
	local stat = uv.fs_stat(path)
	return stat and stat.type == "file" or false
end

--- Checks whether a given path exists and is a directory
--@param path (string) path to check
--@returns (bool)
function M.is_directory(path)
	local stat = uv.fs_stat(path)
	return stat and stat.type == "directory" or false
end

M.join_paths = _G.join_paths

---Write data to a file
---@param path string can be full or relative to `cwd`
---@param txt string|table text to be written, uses `vim.inspect` internally for tables
---@param flag string used to determine access mode, common flags: "w" for `overwrite` or "a" for `append`
function M.write_file(path, txt, flag)
	local data = type(txt) == "string" and txt or vim.inspect(txt)
	uv.fs_open(path, flag, 438, function(open_err, fd)
		assert(not open_err, open_err)
		uv.fs_write(fd, data, -1, function(write_err)
			assert(not write_err, write_err)
			uv.fs_close(fd, function(close_err)
				assert(not close_err, close_err)
			end)
		end)
	end)
end

---Copies a file or directory recursively
---@param source string
---@param destination string
function M.fs_copy(source, destination)
	local source_stats = assert(vim.loop.fs_stat(source))

	if source_stats.type == "file" then
		assert(vim.loop.fs_copyfile(source, destination))
		return
	elseif source_stats.type == "directory" then
		local handle = assert(vim.loop.fs_scandir(source))

		assert(vim.loop.fs_mkdir(destination, source_stats.mode))

		while true do
			local name = vim.loop.fs_scandir_next(handle)
			if not name then
				break
			end

			M.fs_copy(
				M.join_paths(source, name),
				M.join_paths(destination, name)
			)
		end
	end
end

return M
