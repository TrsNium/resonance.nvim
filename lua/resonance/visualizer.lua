local M = {}
local api = vim.api

local state = {
  win_id = nil,
  buf_id = nil,
  timer = nil,
  patterns = {},
  cycle_count = 0,
}

-- ASCII art patterns for visualization
local visuals = {
  kick = {"█▀▀█", "█▄▄█", "▀▀▀▀"},
  snare = {"╔══╗", "║▓▓║", "╚══╝"},
  hihat = {"┌──┐", "│▒▒│", "└──┘"},
  default = {"●──●", "│  │", "●──●"},
}

-- Create or update the visualizer window
function M.toggle()
  if state.win_id and api.nvim_win_is_valid(state.win_id) then
    M.close()
  else
    M.open()
  end
end

function M.open()
  -- Create buffer if needed
  if not state.buf_id or not api.nvim_buf_is_valid(state.buf_id) then
    state.buf_id = api.nvim_create_buf(false, true)
    vim.bo[state.buf_id].filetype = "tidal-viz"
    vim.bo[state.buf_id].bufhidden = "hide"
  end
  
  -- Calculate window size and position
  local width = 40
  local height = 10
  local row = 2
  local col = vim.o.columns - width - 2
  
  -- Create floating window
  state.win_id = api.nvim_open_win(state.buf_id, false, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Pattern Visualizer ",
    title_pos = "center",
  })
  
  -- Set window options
  vim.wo[state.win_id].wrap = false
  vim.wo[state.win_id].cursorline = false
  vim.wo[state.win_id].number = false
  
  -- Start animation timer
  M.start_animation()
end

function M.close()
  if state.timer then
    vim.fn.timer_stop(state.timer)
    state.timer = nil
  end
  
  if state.win_id and api.nvim_win_is_valid(state.win_id) then
    api.nvim_win_close(state.win_id, true)
    state.win_id = nil
  end
end

function M.update_pattern(pattern_string)
  -- Parse pattern string and extract rhythm info
  local drums = {}
  
  -- Simple pattern matching for common drum patterns
  if pattern_string:match("bd") or pattern_string:match("kick") then
    table.insert(drums, { type = "kick", pattern = "x...x..." })
  end
  if pattern_string:match("sn") or pattern_string:match("snare") then
    table.insert(drums, { type = "snare", pattern = "..x...x." })
  end
  if pattern_string:match("hh") or pattern_string:match("hat") then
    table.insert(drums, { type = "hihat", pattern = "xxxxxxxx" })
  end
  
  state.patterns = drums
end

function M.start_animation()
  if state.timer then
    vim.fn.timer_stop(state.timer)
  end
  
  state.timer = vim.fn.timer_start(125, function()
    if not state.win_id or not api.nvim_win_is_valid(state.win_id) then
      return
    end
    
    M.render_frame()
    state.cycle_count = state.cycle_count + 1
  end, { ["repeat"] = -1 })
end

function M.render_frame()
  if not state.buf_id or not api.nvim_buf_is_valid(state.buf_id) then
    return
  end
  
  local lines = {}
  local width = 40
  local beat = (state.cycle_count % 8) + 1
  
  -- Header
  table.insert(lines, string.format(" Cycle: %d | Beat: %d/8 ", 
    math.floor(state.cycle_count / 8), beat))
  table.insert(lines, string.rep("─", width - 2))
  
  -- Beat indicator
  local beat_line = " "
  for i = 1, 8 do
    if i == beat then
      beat_line = beat_line .. "▼ "
    else
      beat_line = beat_line .. "  "
    end
  end
  table.insert(lines, beat_line)
  
  -- Pattern visualization
  for _, drum in ipairs(state.patterns) do
    local visual = visuals[drum.type] or visuals.default
    local pattern = drum.pattern
    
    -- Check if this beat should trigger
    local trigger = pattern:sub(beat, beat) == "x"
    
    -- Add drum lines with animation
    for i, line in ipairs(visual) do
      local display = line
      if trigger then
        -- Animate on trigger
        if i == 2 then
          display = display:gsub(".", "█")
        end
      end
      table.insert(lines, " " .. display .. " " .. drum.type)
    end
    table.insert(lines, "")
  end
  
  -- If no patterns, show waiting message
  if #state.patterns == 0 then
    table.insert(lines, "")
    table.insert(lines, "  Waiting for patterns...")
    table.insert(lines, "  Evaluate some code with <C-e>")
  end
  
  -- Update buffer
  api.nvim_buf_set_lines(state.buf_id, 0, -1, false, lines)
end

-- Integration with REPL evaluation
function M.on_eval(code)
  if state.win_id and api.nvim_win_is_valid(state.win_id) then
    M.update_pattern(code)
  end
end

return M