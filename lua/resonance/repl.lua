local M = {}
local api = vim.api
local fn = vim.fn

local state = {
  job_id = nil,
  buf_id = nil,
  win_id = nil,
  config = {},
}

function M.setup(config)
  state.config = config
end

function M.start()
  if state.job_id then
    vim.notify("TidalCycles REPL is already running", vim.log.levels.WARN)
    return
  end
  
  -- Save current window
  local prev_win = api.nvim_get_current_win()
  
  -- Open window first
  if state.config.window.floating then
    M._open_floating_window()
  else
    M._open_split_window()
  end
  
  -- Now create terminal in the current window
  local utils = require("resonance.utils")
  local cmd_parts = utils.build_repl_command(state.config)
  if not cmd_parts then
    api.nvim_win_close(0, true)
    return
  end
  
  -- Debug: print command parts (commented out for production)
  -- vim.notify("Command parts: " .. vim.inspect(cmd_parts), vim.log.levels.INFO)
  
  -- termopen needs the command as a string or list
  -- For complex commands with many arguments, we need to be careful
  local term_cmd
  if #cmd_parts == 1 then
    term_cmd = cmd_parts[1]
  else
    -- For shell commands, we need to properly escape
    term_cmd = cmd_parts
  end
  
  state.job_id = fn.termopen(term_cmd, {
    on_exit = function(job_id, exit_code, event_type)
      -- Only show exit message if it's an error
      if exit_code ~= 0 then
        vim.notify(string.format("TidalCycles REPL exited with code: %d", exit_code), vim.log.levels.WARN)
        -- Check common exit codes
        if exit_code == 127 then
          vim.notify("Command not found. Check if GHCi is installed.", vim.log.levels.ERROR)
        elseif exit_code == 1 then
          vim.notify("GHCi exited with error. Check the boot script.", vim.log.levels.ERROR)
        end
      end
      M.stop()
    end,
  })
  
  if state.job_id == 0 or state.job_id == -1 then
    vim.notify("Failed to start REPL process", vim.log.levels.ERROR)
    api.nvim_win_close(0, true)
    return
  end
  
  -- Get the buffer that termopen created
  state.buf_id = api.nvim_get_current_buf()
  state.win_id = api.nvim_get_current_win()
  
  -- Go back to previous window
  if api.nvim_win_is_valid(prev_win) then
    api.nvim_set_current_win(prev_win)
  end
  
  vim.notify("TidalCycles REPL started", vim.log.levels.INFO)
end

function M.stop()
  if state.job_id then
    fn.jobstop(state.job_id)
    state.job_id = nil
  end
  
  if state.win_id and api.nvim_win_is_valid(state.win_id) then
    api.nvim_win_close(state.win_id, true)
    state.win_id = nil
  end
  
  if state.buf_id and api.nvim_buf_is_valid(state.buf_id) then
    api.nvim_buf_delete(state.buf_id, { force = true })
    state.buf_id = nil
  end
  
  vim.notify("TidalCycles REPL stopped", vim.log.levels.INFO)
end

function M.send(text)
  if not state.job_id then
    vim.notify("TidalCycles REPL is not running", vim.log.levels.ERROR)
    return false
  end
  
  -- Send text to REPL
  fn.chansend(state.job_id, text .. "\n")
  return true
end

function M.eval_line()
  local line = api.nvim_get_current_line()
  if line:match("^%s*$") then
    return
  end
  
  if M.send(line) then
    require("resonance.ui").flash_line()
  end
end

function M.eval_block()
  local start_line, end_line = M._find_block()
  local lines = api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local text = table.concat(lines, "\n")
  
  if M.send(text) then
    require("resonance.ui").flash_region(start_line, end_line)
  end
end

function M.eval_selection()
  local start_pos = fn.getpos("'<")
  local end_pos = fn.getpos("'>")
  local lines = api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
  
  if #lines == 1 then
    lines[1] = lines[1]:sub(start_pos[3], end_pos[3])
  else
    lines[1] = lines[1]:sub(start_pos[3])
    lines[#lines] = lines[#lines]:sub(1, end_pos[3])
  end
  
  local text = table.concat(lines, "\n")
  if M.send(text) then
    require("resonance.ui").flash_region(start_pos[2], end_pos[2])
  end
end

function M.hush()
  M.send("hush")
end

function M.silence(n)
  n = n or ""
  M.send("d" .. n .. " silence")
end

function M.toggle()
  if state.job_id then
    M.stop()
  else
    M.start()
  end
end

function M.is_running()
  return state.job_id ~= nil
end

function M._find_block()
  local current = fn.line(".")
  local total = fn.line("$")
  local start_line = current
  local end_line = current
  
  -- Find start of block (previous empty line or start of file)
  while start_line > 1 do
    local line = fn.getline(start_line - 1)
    if line:match("^%s*$") then
      break
    end
    start_line = start_line - 1
  end
  
  -- Find end of block (next empty line or end of file)
  while end_line < total do
    local line = fn.getline(end_line + 1)
    if line:match("^%s*$") then
      break
    end
    end_line = end_line + 1
  end
  
  return start_line, end_line
end

function M._open_split_window()
  local position = state.config.window.position
  local size = state.config.window.size
  
  if position == "bottom" then
    vim.cmd("botright " .. size .. "new")
  elseif position == "top" then
    vim.cmd("topleft " .. size .. "new")
  elseif position == "left" then
    vim.cmd("topleft " .. size .. "vnew")
  elseif position == "right" then
    vim.cmd("botright " .. size .. "vnew")
  end
end

function M._open_floating_window()
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.3)
  local row = vim.o.lines - height - 3
  local col = math.floor((vim.o.columns - width) / 2)
  
  -- Create a new buffer for the floating window
  local buf = api.nvim_create_buf(false, true)
  
  state.win_id = api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " TidalCycles REPL ",
    title_pos = "center",
  })
end

return M