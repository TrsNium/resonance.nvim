local M = {}

-- Check if a command exists in the system
function M.command_exists(cmd)
  return vim.fn.executable(cmd) == 1
end

-- Check if we're in a stack project
function M.is_stack_project()
  return vim.fn.filereadable("stack.yaml") == 1 or 
         vim.fn.filereadable("../stack.yaml") == 1 or
         vim.fn.filereadable("../../stack.yaml") == 1
end

-- Find the appropriate GHCi command
function M.find_ghci_command()
  -- Priority order: user config > stack project > stack global > ghci
  local commands = {}
  
  -- If in a stack project, prefer stack exec
  if M.is_stack_project() then
    table.insert(commands, { cmd = "stack", args = { "exec", "--", "ghci" }, name = "stack ghci (project)" })
  end
  
  -- Global options
  table.insert(commands, { cmd = "stack", args = { "exec", "--resolver", "lts", "--", "ghci", "-package", "tidal" }, name = "stack ghci (global)" })
  table.insert(commands, { cmd = "ghci", args = {}, name = "ghci" })
  
  for _, config in ipairs(commands) do
    if M.command_exists(config.cmd) then
      return config
    end
  end
  
  return nil
end

-- Get the full command with arguments
function M.get_ghci_command(user_config)
  -- If user explicitly set a command, use it
  if user_config and user_config.cmd then
    return {
      cmd = user_config.cmd,
      args = user_config.args or {},
      name = "user configured"
    }
  end
  
  -- Otherwise, auto-detect
  local detected = M.find_ghci_command()
  if not detected then
    vim.notify("No GHCi command found. Please install GHC or Stack.", vim.log.levels.ERROR)
    return nil
  end
  
  -- vim.notify("Using " .. detected.name .. " for TidalCycles", vim.log.levels.INFO)
  return detected
end

-- Build the full command line for the REPL
function M.build_repl_command(repl_config)
  local ghci_config = M.get_ghci_command(repl_config)
  if not ghci_config then
    return nil
  end
  
  local cmd_parts = { ghci_config.cmd }
  vim.list_extend(cmd_parts, ghci_config.args)
  
  -- Add boot script
  local boot_script = vim.fn.stdpath("data") .. "/resonance/BootTidal.hs"
  table.insert(cmd_parts, "-ghci-script")
  table.insert(cmd_parts, boot_script)
  
  -- Add any additional user args
  if repl_config.extra_args then
    vim.list_extend(cmd_parts, repl_config.extra_args)
  end
  
  -- Debug: print the full command (commented out for production)
  -- vim.notify("Starting REPL with: " .. table.concat(cmd_parts, " "), vim.log.levels.INFO)
  
  return cmd_parts
end

return M