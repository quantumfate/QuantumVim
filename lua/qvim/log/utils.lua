local M = {}

local initial_log_call = { max_parents = 5, stack_level = 6 }
---Crates a loppipeline for structured logging with a `stack_level=6` for each channel because it takes exactly
---`6` stack calls from the initial log call to the internal log call writing to the target sink.
---@param log StructlogImpl The logger instance
---@param structlog table The structlog instace
---@param name string Name of the pipeline
---@return table<table> t
function M.get_basic_pipelines(log, structlog, name)
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
    }
end

---Fetches pipelines that needs to be added after plugin initialization
---@param structlog table The structlog instace
---@return table t
function M.get_additional_pipeline(structlog)
    return {
        level = structlog.level.WARN,
        processors = {},
        formatter = structlog.formatters.Format(
            "%s",
            { "msg" },
            { blacklist = { "level", "logger_name" } }
        ),
        sink = structlog.sinks.NvimNotify(),
    }
end

return M
