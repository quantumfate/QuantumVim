local utils = require("qvim.log.utils")

local fmt = string.format

---@class StructlogImpl
---@field levels table
---@field setup fun(self: StructlogImpl, channels: table, log: Log):StructlogImpl?
---@field add_entry function
---@field get_logger function
---@field get_path fun(variant: string?, channel: string?):string
---@field info fun(self: StructlogImpl, msg: string, channel: string?, event: table?)
---@field trace fun(self: StructlogImpl, msg: string, channel: string?, event: table?)
---@field debug fun(self: StructlogImpl, msg: string, channel: string?, event: table?)
---@field warn fun(self: StructlogImpl, msg: string, channel: string?, event: table?)
---@field error fun(self: StructlogImpl, msg: string, channel: string?, event: table?)
local StructlogImpl = {}

local Log_mt = { __index = StructlogImpl }

StructlogImpl.levels = {
	TRACE = 1,
	DEBUG = 2,
	INFO = 3,
	WARN = 4,
	ERROR = 5,
}
vim.tbl_add_reverse_lookup(StructlogImpl.levels)

---@param t any
---@param predicate fun(entry: any):boolean
---@return boolean
local function any(t, predicate)
	for _, entry in pairs(t) do
		if predicate(entry) then
			return true
		end
	end
	return false
end

local possible_functions = { "info", "debug", "warn", "error", "trace" }

local structlog
local status_ok

---Setup Structlog with its channels and mutates the log table to index the log functions
---@param self StructlogImpl
---@param channels table<string, table>
---@param log Log
---@return StructlogImpl?
function StructlogImpl:setup(channels, log)
	status_ok, structlog = pcall(require, "structlog")
	if not status_ok then
		return nil
	end

	local opts = {}

	for _, channel in pairs(vim.tbl_keys(channels)) do
		opts[channel] = {
			pipelines = utils.get_basic_pipelines(self, structlog, channel),
		}
		log[channel] = setmetatable({
			channel = channel,
		}, {
			---@param tbl AbstractLog
			---@param key function<AbstractLog>
			---@return function
			__index = function(tbl, key)
				if
					any(possible_functions, function(entry)
						return key == entry
					end)
				then
					return function(msg, event)
						self[key](self, msg, tbl.channel, event)
					end
				end

				if key == "log_file_path" then
					return function(kind)
						return self.get_path(tbl.channel, kind)
					end
				end

				self:error(
					"Illegal function call.",
					"qvim",
					{ error = "None existing function call on a Log instance." }
				)
			end,
		})
	end
	structlog.configure(opts)
	setmetatable(self, Log_mt)
	return self
end

---Update the structlog configuration with stuff thats available once plugins are loaded.
---@param channels table<string, table>
---@return StructlogImpl?
function StructlogImpl:update(channels)
	for _, channel in pairs(vim.tbl_keys(channels)) do
		local pipeline_ok, pipeline = pcall(utils.get_additional_pipeline, structlog)
		if not pipeline_ok then
			self:error(fmt("Failed to update '%s' logger with additional pipelines.", channel), "qvim",
				{ error = "Pipeline depends on missing plugins." })
			return nil
		end
		structlog.get_logger(channel):add_pipeline(pipeline)
	end
	return self
end

---@param level integer [same as vim.log.levels]
---@param msg any
---@param event any
---@param channel table
function StructlogImpl:add_entry(level, msg, event, channel)
	channel = channel or "qvim"
	if
		not pcall(function()
			local logger = self:get_logger(channel)
			if not logger then
				return
			end
			logger[StructlogImpl.levels[level]:lower()](logger, msg, event)
		end)
	then
		vim.notify(msg, level, { title = channel })
	end
end

---Retrieves the handle of the logger object
---@param channel string|nil
---@return table|nil logger handle if found
function StructlogImpl:get_logger(channel)
	channel = channel or "qvim"
	local logger_ok, logger = pcall(function()
		return require("structlog").get_logger(channel)
	end)
	if logger_ok and logger then
		return logger
	end
end

---Retrieves the path of the logfile
---@param variant string?
---@param channel string?
---@return string path of the logfile
function StructlogImpl.get_path(variant, channel)
	variant = variant or "info"
	channel = channel or "qvim"

	local path = channel == "qvim" and "%s/%s-%s.log" or "%s/%s/%s.log"
	return fmt(path, get_qvim_log_dir(), channel, variant)
end

---Add a log entry at TRACE level
---@param self StructlogImpl
---@param msg any
---@param channel string|nil
---@param event any
function StructlogImpl:trace(msg, channel, event)
	self:add_entry(self.levels.TRACE, msg, event, channel)
end

---Add a log entry at DEBUG level
---@param self StructlogImpl
---@param msg any
---@param channel string|nil
---@param event any
function StructlogImpl:debug(msg, channel, event)
	self:add_entry(self.levels.DEBUG, msg, event, channel)
end

---Add a log entry at INFO level
---@param self StructlogImpl
---@param msg any
---@param channel string|nil
---@param event any
function StructlogImpl:info(msg, channel, event)
	self:add_entry(self.levels.INFO, msg, event, channel)
end

---Add a log entry at WARN level
---@param self StructlogImpl
---@param msg any
---@param channel string|nil
---@param event any
function StructlogImpl:warn(msg, channel, event)
	self:add_entry(self.levels.WARN, msg, event, channel)
end

---Add a log entry at ERROR level
---@param self StructlogImpl
---@param msg any
---@param channel string?
---@param event any?
function StructlogImpl:error(msg, channel, event)
	self:add_entry(self.levels.ERROR, msg, event, channel)
end

return StructlogImpl
