local status_ok, configs = pcall(require, "which-key")
if not status_ok then
  return
end

configs.setup {
}
