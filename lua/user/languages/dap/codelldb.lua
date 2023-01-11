
local status_ok, codelldb = pcall(require, "codelldb")
if not status_ok then
  return
end


codelldb.adapters.codelldb = {
  type = 'server',
  port = "${port}",
  executable = {
    -- CHANGE THIS to your path!
    command = 'codelldb', -- its in path
    args = {"--port", "${port}"},

  }
}
