local utils = require("user.languages.utils.util")
local codelldb = utils:require_module("codelldb")

codelldb.adapters.codelldb = {
  type = 'server',
  port = "${port}",
  executable = {
    -- CHANGE THIS to your path!
    command = 'codelldb', -- its in path
    args = {"--port", "${port}"},

  }
}
