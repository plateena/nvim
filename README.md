# Neovim Config

Personal Neovim configuration. Versioned setup — active version loaded via `init.lua`.

## Structure

```
~/.config/nvim/
├── init.lua                 # Entry point: loads config/ + active version
├── lua/
│   ├── config/              # Shared across all versions
│   │   ├── options.lua      # vim.opt settings
│   │   ├── keymaps.lua      # Global keymaps
│   │   ├── autocmds.lua     # Auto-commands (save, restore, etc.)
│   │   └── macros.lua       # Saved macros
│   ├── v6/                  # Active version
│   │   ├── init.lua         # Loads lazy.lua + lsp.lua
│   │   ├── lazy.lua         # Plugin manager bootstrap
│   │   ├── lsp.lua          # Built-in LSP config (Neovim 0.12+)
│   │   └── plugins/         # Plugin specs (one per file)
│   ├── v5/                  # Previous version (rollback)
│   └── myplugin/            # Custom local plugins
├── after/
│   ├── plugin/theme.lua     # Colorscheme + highlight overrides
│   └── ftplugin/            # Filetype-specific settings
└── snippets/                # Custom LuaSnip snippets
```

## Version System

Config versions live in `lua/v5/`, `lua/v6/`, etc. Switch by editing `init.lua`:

```lua
-- require("v5")
require("v6")
```

## Key Mappings

Leader: `<Space>`

### General

| Key | Action |
|-----|--------|
| `<leader>w` | Write file |
| `<leader>qq` | Quit |
| `<Esc>` | Clear search highlight |
| `jk` | Escape (insert mode) |
| `<C-h/j/k/l>` | Window navigation (tmux-aware) |
| `<S-Arrow>` | Resize windows |

### Clipboard

| Key | Action |
|-----|--------|
| `<leader>y` | Yank to system clipboard |
| `<leader>Y` | Yank line to clipboard |
| `<leader>p` | Paste from clipboard |
| `<leader>d` | Delete to void register |
| `<leader>yf` | Yank full file path |
| `<leader>yr` | Yank relative file path |
| `<leader>yn` | Yank filename only |

### Buffers

| Key | Action |
|-----|--------|
| `[b` / `]b` | Previous/next buffer |
| `<leader>bd` | Delete buffer |
| `<leader>n` | Buffer picker |

### Find (Snacks Picker)

| Key | Action |
|-----|--------|
| `<leader>ff` | Find all files |
| `<leader>fF` | Live grep |
| `<leader>fg` | Git files |
| `<leader>fa` | Git status |
| `<leader>fh` | Recent files |
| `<leader>fr` | Resume last picker |
| `<leader>fs` | Grep string |
| `<leader>fp` | Projects |
| `<leader>fk` | Keymaps |

### LSP

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | References |
| `gy` | Type definition |
| `K` | Hover |
| `<C-k>` | Signature help |
| `<leader>la` | Code action |
| `<leader>lr` | Rename |
| `<leader>ls` | Document symbols |
| `<leader>lS` | Workspace symbols |
| `<leader>li` | Toggle inlay hints |
| `<leader>ld` | Toggle diagnostics |
| `[d` / `]d` | Previous/next diagnostic |

### Git

| Key | Action |
|-----|--------|
| `]h` / `[h` | Next/prev hunk |
| `<leader>gs` | Stage hunk |
| `<leader>gr` | Reset hunk |
| `<leader>gp` | Preview hunk |
| `<leader>gb` | Blame line |
| `<leader>gt` | Toggle line blame |
| `<leader>gd` | Diffview open |
| `<leader>gh` | File history |
| `<leader>gg` | Lazygit |

### File Explorer

| Key | Action |
|-----|--------|
| `-` | Oil (parent directory) |
| `<leader>eO` | Oil (project root) |
| `<leader>ee` | Snacks explorer |

### Flash (Jump)

| Key | Action |
|-----|--------|
| `s` | Flash jump (type target chars) |
| `S` | Flash treesitter select |
| `f`/`t` | Enhanced with labels |
| `<C-s>` | Toggle flash in search mode |

### Align

| Key | Action |
|-----|--------|
| `ga` | Align (select lines → ga → split char) |
| `gA` | Align with live preview |

### Wiki

| Key | Action |
|-----|--------|
| `<leader>ww` | Wiki index |
| `<leader>wn` | Wiki open |
| `<leader>wt` | Wiki tags |

### Harpoon

| Key | Action |
|-----|--------|
| `<leader>ha` | Add file |
| `<C-e>` | Quick menu |
| `<Alt-1..5>` | Jump to file 1-5 |
| `<Alt-h/l>` | Previous/next |

### AI (CodeCompanion)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ai` | n, v | Toggle AI chat |
| `<leader>aa` | n, v | AI actions (prompt library) |
| `<leader>ac` | v | Add selection to chat |
| `<leader>ac` | n | Add entire file to chat |
| `<leader>af` | v | Fix code (selection) |
| `<leader>af` | n | Fix code (entire file) |
| `<leader>ae` | v | Explain code (selection) |
| `<leader>ae` | n | Explain code (entire file) |
| `<leader>at` | v | Generate tests (selection) |
| `<leader>at` | n | Generate tests (entire file) |

In chat buffer:

| Key | Action |
|-----|--------|
| `gh` | Open chat history |
| `sc` | Save current chat |

#### Actions / Prompt Library

Available via `<leader>aa` or `:CodeCompanionActions`. Adapter: Kiro (via ACP).

| Action | Type | Description |
|--------|------|-------------|
| Akai | chat | Full Akai persona (all core + skills) |
| Akai Laravel | chat | Laravel API development |
| Akai Rails | chat | Legacy Rails work |
| Akai Neovim | chat | Neovim config help |
| Akai Debug | chat | Debugging session |
| Akai DevOps | chat | Docker, AWS, deployment |
| Akai Docs | chat | Technical documentation |
| Akai Refactor | chat | Safe refactoring |
| Akai Postgres | chat | PostgreSQL queries/optimization |
| Akai Playwright | chat | ATS Playwright automation |
| Akai Bash | chat | Bash automation scripts |
| Akai Jira | chat | Generate Jira tickets |
| Akai Review | chat | Code review (supports visual selection) |
| PR Check | chat | Validate branch for PR readiness (auto-submit) |
| PR Review | chat | Code review branch diff (auto-submit) |
| Project Refactor | inline | Refactor file following project conventions (auto-submit) |

Actions load context from `~/ai/` (persona, rules, skills) and `.ai/` (project-level) automatically.

### Terminal

| Key | Action |
|-----|--------|
| `<C-/>` | Toggle floating terminal |
| `<C-t>` | Exit terminal mode |

## Plugins (v6)

| Plugin | Purpose |
|--------|---------|
| lazy.nvim | Plugin manager |
| snacks.nvim | Picker, explorer, dashboard, notifications, terminal |
| blink.cmp | Autocompletion |
| nvim-treesitter | Syntax highlighting + textobjects |
| conform.nvim | Formatting (format-on-save) |
| nvim-lint | Async linting |
| flash.nvim | Jump anywhere in 2-3 keystrokes |
| gitsigns.nvim | Git hunks, blame, staging |
| diffview.nvim | Git diff viewer |
| oil.nvim | File explorer (buffer-based) |
| harpoon | Quick file switching |
| LuaSnip | Snippets |
| which-key.nvim | Keymap hints |
| lualine.nvim | Statusline |
| todo-comments.nvim | TODO/FIXME highlighting |
| mini.icons | Icons |
| mini.ai | Better text objects |
| mini.align | Align text on any character |
| mini.pairs | Auto pairs |
| nvim-surround | Surround operations |
| transparent.nvim | Transparent background |
| wiki.vim | Personal wiki (markdown) |
| icon-picker.nvim | Emoji/nerd font picker |
| codecompanion.nvim | AI chat (Kiro via ACP) |
| amazonq.nvim | Inline AI completions |

## LSP Servers

| Server | Language |
|--------|----------|
| lua_ls | Lua/Neovim |
| tsserver | TypeScript/JavaScript |
| phpactor | PHP |
| pylsp | Python |
| bashls | Bash/Zsh |

Additional servers installed via Mason: `cssls`, `dockerls`, `docker_compose_language_service`, `emmet_ls`, `jsonls`, `ruby_lsp`, `sqlls`, `tailwindcss`, `yamlls`.

## Formatters

| Filetype | Formatter |
|----------|-----------|
| PHP | prettierd → phpcbf (PSR-12) |
| JS/TS/HTML/CSS | prettierd → prettier |
| Ruby | rubocop |
| Lua | stylua |
| Bash | shfmt |

## Requirements

- Neovim 0.12+
- Git
- Node.js (for LSP servers)
- ripgrep (for grep picker)
- fd (for file picker)
- lazygit (optional, for `<leader>gg`)
