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
  
  -- Create buffer for REPL
  state.buf_id = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(state.buf_id, "buftype", "terminal")
  api.nvim_buf_set_option(state.buf_id, "buflisted", false)
  
  -- Open window
  if state.config.window.floating then
    M._open_floating_window()
  else
    M._open_split_window()
  end
  
  -- Start REPL process
  local cmd = { state.config.cmd }
  vim.list_extend(cmd, state.config.args or {})
  
  state.job_id = fn.termopen(table.concat(cmd, " "), {
    on_exit = function()
      M.stop()
    end,
  })
  
  -- Go back to previous window
  vim.cmd("wincmd p")
  
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
    vim.cmd("botright " .. size .. "split")
  elseif position == "top" then
    vim.cmd("topleft " .. size .. "split")
  elseif position == "left" then
    vim.cmd("topleft " .. size .. "vsplit")
  elseif position == "right" then
    vim.cmd("botright " .. size .. "vsplit")
  end
  
  state.win_id = api.nvim_get_current_win()
  api.nvim_win_set_buf(state.win_id, state.buf_id)
end

function M._open_floating_window()
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.3)
  local row = vim.o.lines - height - 3
  local col = math.floor((vim.o.columns - width) / 2)
  
  state.win_id = api.nvim_open_win(state.buf_id, true, {
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