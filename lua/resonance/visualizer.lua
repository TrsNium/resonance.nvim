local M = {}
local api = vim.api

local state = {
  win_id = nil,
  buf_id = nil,
  timer = nil,
  patterns = {},
  cycle_count = 0,
  -- Track multiple channels
  channels = {}, -- d1 through d12
  active_channels = {},
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
  
  -- Calculate window size and position (larger for multi-channel view)
  local width = 55
  local height = 20
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
  
  -- Protect against nil or invalid input
  if not pattern_string or type(pattern_string) ~= "string" then
    return
  end
  
  -- Simple pattern matching for common drum patterns
  if pattern_string:match("bd") or pattern_string:match("kick") or pattern_string:match("808bd") then
    table.insert(drums, { type = "kick", pattern = "x...x..." })
  end
  if pattern_string:match("sn") or pattern_string:match("snare") or pattern_string:match("808sd") then
    table.insert(drums, { type = "snare", pattern = "..x...x." })
  end
  if pattern_string:match("hh") or pattern_string:match("hat") or pattern_string:match("808oh") then
    table.insert(drums, { type = "hihat", pattern = "xxxxxxxx" })
  end
  if pattern_string:match("cp") or pattern_string:match("clap") then
    table.insert(drums, { type = "default", pattern = "....x..." })
  end
  
  -- Handle melodic patterns differently
  if pattern_string:match("arpy") or pattern_string:match("up") then
    table.insert(drums, { type = "default", pattern = "x.x.x.x." })
  end
  
  -- Only update if we found patterns
  if #drums > 0 then
    state.patterns = drums
  end
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
  local width = 50
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
  table.insert(lines, "")
  
  -- Active channels visualization
  local has_active = false
  for i = 1, 12 do
    local channel = "d" .. i
    if state.active_channels[channel] and state.channels[channel] then
      has_active = true
      local pattern = state.channels[channel]
      
      -- Channel header
      table.insert(lines, string.format("═══ %s ═══", channel))
      
      -- Show sounds for this channel
      local sound_line = "  "
      for idx, sound in ipairs(pattern.sounds) do
        -- Simple beat pattern based on sound position
        local is_active = ((beat - 1 + idx - 1) % 8) < 2
        if is_active then
          sound_line = sound_line .. "[" .. sound .. "] "
        else
          sound_line = sound_line .. " " .. sound .. "  "
        end
      end
      table.insert(lines, sound_line)
      
      -- Visual representation
      local viz_line = "  "
      for b = 1, 8 do
        if b == beat then
          viz_line = viz_line .. "█ "
        else
          viz_line = viz_line .. "░ "
        end
      end
      table.insert(lines, viz_line)
      table.insert(lines, "")
    end
  end
  
  -- Show all channels status
  table.insert(lines, "─── Channels ───")
  local channel_status = " "
  for i = 1, 12 do
    local ch = "d" .. i
    if state.active_channels[ch] then
      channel_status = channel_status .. string.format("[%s] ", ch)
    else
      channel_status = channel_status .. string.format(" %s  ", ch)
    end
    if i == 6 then
      table.insert(lines, channel_status)
      channel_status = " "
    end
  end
  table.insert(lines, channel_status)
  
  -- If no patterns, show waiting message
  if not has_active then
    table.insert(lines, "")
    table.insert(lines, "  No active patterns...")
    table.insert(lines, "  Evaluate some code with <C-e>")
  end
  
  -- Update buffer safely
  vim.schedule(function()
    if api.nvim_buf_is_valid(state.buf_id) then
      api.nvim_buf_set_lines(state.buf_id, 0, -1, false, lines)
    end
  end)
end

-- Integration with REPL evaluation
function M.on_eval(code)
  if state.win_id and api.nvim_win_is_valid(state.win_id) then
    -- Extract channel number (d1, d2, etc.)
    local channel = code:match("^%s*(d%d+)")
    if channel then
      -- Update specific channel
      M.update_channel(channel, code)
    else
      -- Legacy single pattern update
      M.update_pattern(code)
    end
  end
end

-- Update a specific channel with pattern
function M.update_channel(channel, code)
  if not channel or not code then
    return
  end
  
  -- Parse the pattern for this channel
  local pattern_info = M.parse_pattern(code)
  if pattern_info then
    state.channels[channel] = pattern_info
    state.active_channels[channel] = true
  elseif code:match("silence") then
    -- Handle silence command
    state.active_channels[channel] = false
  end
end

-- Parse pattern string and return pattern info
function M.parse_pattern(pattern_string)
  local sounds = {}
  
  -- Extract sound patterns
  local sound_pattern = pattern_string:match('sound%s*"([^"]+)"') or 
                       pattern_string:match('s%s*"([^"]+)"')
  
  if sound_pattern then
    -- Split by spaces to get individual sounds
    for sound in sound_pattern:gmatch("%S+") do
      local base_sound = sound:match("^([^:*]+)")
      if base_sound then
        table.insert(sounds, base_sound)
      end
    end
  end
  
  -- Return pattern info if we found sounds
  if #sounds > 0 then
    return {
      sounds = sounds,
      code = pattern_string,
      timestamp = vim.loop.now(),
    }
  end
  
  return nil
end

-- Clear all channels (for hush)
function M.clear_all()
  state.channels = {}
  state.active_channels = {}
end

return M