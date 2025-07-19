local M = {}
local api = vim.api

local ns_id = api.nvim_create_namespace("resonance_eval")

function M.flash_line(line)
  line = line or vim.fn.line(".")
  M.flash_region(line, line)
end

function M.flash_region(start_line, end_line)
  local config = require("resonance").config
  if not config.ui.show_eval_flash then
    return
  end
  
  local buf = api.nvim_get_current_buf()
  
  -- Add highlight
  for line = start_line, end_line do
    api.nvim_buf_add_highlight(buf, ns_id, "Visual", line - 1, 0, -1)
  end
  
  -- Remove highlight after duration
  vim.defer_fn(function()
    api.nvim_buf_clear_namespace(buf, ns_id, start_line - 1, end_line)
  end, config.ui.eval_flash_duration)
end

function M.show_error(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = "TidalCycles" })
end

function M.show_info(msg)
  vim.notify(msg, vim.log.levels.INFO, { title = "TidalCycles" })
end

return M