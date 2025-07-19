local M = {}

function M.setup()
  local repl = require("resonance.repl")
  
  -- REPL control commands
  vim.api.nvim_create_user_command("TidalStart", function()
    repl.start()
  end, { desc = "Start TidalCycles REPL" })
  
  vim.api.nvim_create_user_command("TidalStop", function()
    repl.stop()
  end, { desc = "Stop TidalCycles REPL" })
  
  vim.api.nvim_create_user_command("TidalToggle", function()
    repl.toggle()
  end, { desc = "Toggle TidalCycles REPL" })
  
  -- Evaluation commands
  vim.api.nvim_create_user_command("TidalEval", function(opts)
    if opts.range > 0 then
      repl.eval_selection()
    else
      local line = vim.api.nvim_get_current_line()
      if line:match("^%s*$") then
        repl.eval_block()
      else
        repl.eval_line()
      end
    end
  end, { range = true, desc = "Evaluate TidalCycles code" })
  
  vim.api.nvim_create_user_command("TidalEvalLine", function()
    repl.eval_line()
  end, { desc = "Evaluate current line" })
  
  vim.api.nvim_create_user_command("TidalEvalBlock", function()
    repl.eval_block()
  end, { desc = "Evaluate current block" })
  
  -- Pattern control commands
  vim.api.nvim_create_user_command("TidalHush", function()
    repl.hush()
  end, { desc = "Stop all patterns" })
  
  vim.api.nvim_create_user_command("TidalSilence", function(opts)
    repl.silence(opts.args)
  end, { nargs = "?", desc = "Silence pattern (default: d1)" })
  
  -- Utility commands
  vim.api.nvim_create_user_command("TidalStatus", function()
    if repl.is_running() then
      vim.notify("TidalCycles REPL is running", vim.log.levels.INFO)
    else
      vim.notify("TidalCycles REPL is not running", vim.log.levels.WARN)
    end
  end, { desc = "Show REPL status" })
end

return M