local M = {}

M.config = {
  repl = {
    cmd = nil, -- Auto-detect by default (stack ghci or ghci)
    args = {}, -- Additional arguments
    extra_args = {}, -- Extra arguments after boot script
    auto_start = false,
    window = {
      position = "bottom",
      size = 10,
      floating = false,
    },
  },
  ui = {
    show_eval_flash = true,
    eval_flash_duration = 150,
  },
  keymaps = {
    eval_line = "<C-e>",
    eval_block = "<C-e>",
    hush = "<leader>th",
    toggle_repl = "<leader>tt",
    silence = "<leader>ts",
  },
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  
  -- Load modules
  require("resonance.repl").setup(M.config.repl)
  require("resonance.commands").setup()
  require("resonance.keymaps").setup(M.config.keymaps)
  
  -- Create data directory if needed
  local data_dir = vim.fn.stdpath("data") .. "/resonance"
  if vim.fn.isdirectory(data_dir) == 0 then
    vim.fn.mkdir(data_dir, "p")
  end
  
  -- Copy boot file if not exists
  local boot_file = data_dir .. "/BootTidal.hs"
  if vim.fn.filereadable(boot_file) == 0 then
    require("resonance.boot").create_boot_file(boot_file)
  end
end

return M