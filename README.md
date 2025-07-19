# resonance.nvim

A modern Neovim plugin for TidalCycles live coding.

## Features

- Modern Lua API
- Asynchronous REPL communication
- Built-in syntax highlighting and indentation
- Smart code evaluation (blocks, lines, patterns)
- Visual feedback for evaluated code
- Integrated documentation viewer
- Pattern visualization (planned)

## Requirements

- Neovim >= 0.8.0
- TidalCycles installed
- GHCi (via GHC or Stack)
- SuperCollider (for audio)

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "TrsNium/resonance.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("resonance").setup()
  end,
}
```

## Usage

Basic commands:

- `:TidalStart` - Start TidalCycles REPL
- `:TidalStop` - Stop TidalCycles REPL
- `:TidalEval` - Evaluate current line/selection
- `:TidalHush` - Stop all patterns

Default keymaps:

- `<C-e>` - Evaluate current line/block
- `<leader>th` - Hush all patterns
- `<leader>ts` - Show REPL status

## Configuration

```lua
require("resonance").setup({
  -- REPL settings
  repl = {
    -- Auto-detects: stack ghci > ghci
    -- Or specify manually:
    -- cmd = "stack",
    -- args = { "exec", "--", "ghci" },
    
    -- For custom installations:
    -- cmd = "/path/to/ghci",
    -- args = {},
    
    extra_args = {}, -- Additional args after boot script
    auto_start = false,
  },
  
  -- UI settings
  ui = {
    show_eval_flash = true,
    eval_flash_duration = 150,
    floating_repl = true,
  },
  
  -- Keymaps
  keymaps = {
    eval_line = "<C-e>",
    eval_block = "<C-e>",
    hush = "<leader>th",
    toggle_repl = "<leader>tt",
  },
})
```

## Architecture

```mermaid
graph TB
    subgraph "Neovim"
        A[resonance.nvim Plugin]
        B[Lua API]
        C[Terminal Buffer]
        D[Keymaps/Commands]
    end
    
    subgraph "TidalCycles"
        E[GHCi REPL]
        F[Tidal Library]
        G[OSC Messages]
    end
    
    subgraph "SuperCollider"
        H[SuperDirt]
        I[Audio Engine]
        J[Sound Samples]
    end
    
    subgraph "User Interface"
        K[.tidal files]
        L[Live Coding]
    end
    
    K --> D
    D --> B
    B --> A
    A --> C
    C --> E
    E --> F
    F --> G
    G --> H
    H --> I
    I --> J
    J --> M[Audio Output]
    
    style A fill:#f9f,stroke:#333,stroke-width:4px
    style F fill:#9ff,stroke:#333,stroke-width:2px
    style H fill:#ff9,stroke:#333,stroke-width:2px
```

### Component Overview

```mermaid
graph LR
    subgraph "resonance.nvim Structure"
        Init[init.lua<br/>Main entry point]
        Repl[repl.lua<br/>REPL management]
        Commands[commands.lua<br/>Vim commands]
        Keymaps[keymaps.lua<br/>Key bindings]
        Utils[utils.lua<br/>Helper functions]
        UI[ui.lua<br/>Visual feedback]
        Boot[boot.lua<br/>Tidal boot script]
    end
    
    Init --> Repl
    Init --> Commands
    Init --> Keymaps
    Commands --> Repl
    Keymaps --> Repl
    Repl --> Utils
    Repl --> UI
    Init --> Boot
```

### Data Flow

```mermaid
sequenceDiagram
    participant User
    participant Neovim
    participant resonance.nvim
    participant GHCi
    participant SuperDirt
    participant Audio
    
    User->>Neovim: :TidalStart
    Neovim->>resonance.nvim: setup()
    resonance.nvim->>resonance.nvim: detect GHCi command
    resonance.nvim->>GHCi: start REPL process
    GHCi->>GHCi: load BootTidal.hs
    GHCi->>SuperDirt: connect (port 57120)
    
    User->>Neovim: <C-e> (evaluate)
    Neovim->>resonance.nvim: eval_line()
    resonance.nvim->>GHCi: send pattern
    GHCi->>SuperDirt: OSC messages
    SuperDirt->>Audio: generate sound
    
    resonance.nvim->>Neovim: flash visual feedback
```

### Module Responsibilities

| Module | Responsibility |
|--------|---------------|
| `init.lua` | Plugin initialization, configuration management |
| `repl.lua` | Terminal buffer creation, process management |
| `commands.lua` | Vim command definitions (`:TidalStart`, etc.) |
| `keymaps.lua` | Key binding setup for .tidal files |
| `utils.lua` | GHCi detection, command building |
| `ui.lua` | Visual feedback, error messages |
| `boot.lua` | TidalCycles boot script generation |

## License

MIT
