local M = {}

function M.setup(keymaps)
  local repl = require("resonance.repl")
  
  -- Set up keymaps for tidal files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "tidal",
    callback = function(event)
      local opts = { buffer = event.buf, silent = true }
      
      -- Evaluation keymaps
      vim.keymap.set("n", keymaps.eval_line, function()
        local line = vim.api.nvim_get_current_line()
        if line:match("^%s*$") then
          repl.eval_block()
        else
          repl.eval_line()
        end
      end, vim.tbl_extend("force", opts, { desc = "Evaluate line/block" }))
      
      vim.keymap.set("v", keymaps.eval_line, function()
        repl.eval_selection()
      end, vim.tbl_extend("force", opts, { desc = "Evaluate selection" }))
      
      -- Pattern control keymaps
      vim.keymap.set("n", keymaps.hush, function()
        repl.hush()
      end, vim.tbl_extend("force", opts, { desc = "Hush all patterns" }))
      
      vim.keymap.set("n", keymaps.silence, function()
        vim.ui.input({ prompt = "Pattern to silence (default: 1): " }, function(input)
          repl.silence(input)
        end)
      end, vim.tbl_extend("force", opts, { desc = "Silence pattern" }))
      
      -- REPL control keymaps
      vim.keymap.set("n", keymaps.toggle_repl, function()
        repl.toggle()
      end, vim.tbl_extend("force", opts, { desc = "Toggle REPL" }))
    end,
  })
end

return M