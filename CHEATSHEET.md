# Neovim Cheatsheet

Generated from live keymaps. Run `:Cheatsheet` to refresh.

_Last generated: 2026-09-26 22:39_

## AI

| Key | Mode | Action |
|-----|------|--------|
| `<leader>aa` | Normal | AI Actions |
| `<leader>ac` | Normal | AI Add to chat (file) |
| `<leader>ac` | Visual | AI Add to chat |
| `<leader>ae` | Normal | AI Explain (file) |
| `<leader>ae` | Visual | AI Explain |
| `<leader>af` | Normal | AI Fix code (file) |
| `<leader>af` | Visual | AI Fix code |
| `<leader>ai` | Normal | AI Chat toggle |
| `<leader>at` | Visual | AI Generate tests |
| `<leader>at` | Normal | AI Generate tests (file) |

## Buffer

| Key | Mode | Action |
|-----|------|--------|
| `<leader>bD` | Normal | Delete all buffers |
| `<leader>bd` | Normal | Delete buffer |

## Diagnostics/Quickfix

| Key | Mode | Action |
|-----|------|--------|
| `<leader>xQ` | Normal | Close quickfix |
| `<leader>xb` | Normal | Buffer diagnostics |
| `<leader>xq` | Normal | Open quickfix |
| `<leader>xx` | Normal | Diagnostics |

## Explorer

| Key | Mode | Action |
|-----|------|--------|
| `<leader>eO` | Normal | Oil root dir |
| `<leader>eo` | Normal | Oil file manager |

## Find

| Key | Mode | Action |
|-----|------|--------|
| `<leader>fA` | Normal | Find file |
| `<leader>fD` | Normal | Grep in directory |
| `<leader>fF` | Normal | Live grep |
| `<leader>fR` | Normal | Registers |
| `<leader>fS` | Normal | Search history |
| `<leader>fW` | Normal | Grep cword |
| `<leader>fa` | Normal | Git status |
| `<leader>fc` | Normal | Command history |
| `<leader>ff` | Normal | Find ALL files |
| `<leader>fg` | Normal | Git files |
| `<leader>fh` | Normal | Recent files |
| `<leader>fj` | Normal | Jumplist |
| `<leader>fk` | Normal | Keymaps |
| `<leader>fl` | Normal | Buffer lines |
| `<leader>fm` | Normal | Marks |
| `<leader>fp` | Normal | Projects |
| `<leader>fr` | Normal | Resume |
| `<leader>fs` | Normal | Grep string |

## Format

| Key | Mode | Action |
|-----|------|--------|
| `<leader>mp` | Normal | Format code |

## General

| Key | Mode | Action |
|-----|------|--------|
| `#` | Visual | :help v_#-default |
| `&` | Normal | :help &-default |
| `*` | Normal | Search word without jumping |
| `*` | Visual | :help v_star-default |
| `-` | Normal | Oil file manager |
| `<C-/>` | Normal | Toggle terminal |
| `<C-E>` | Normal | Harpoon menu |
| `<C-H>` | Normal | Move left (vim/tmux) |
| `<C-J>` | Normal | Move down (vim/tmux) |
| `<C-K>` | Normal | Move up (vim/tmux) |
| `<C-L>` | Normal | Move right (vim/tmux) |
| `<C-S>` | Insert | vim.lsp.buf.signature_help() |
| `<C-S>` | Command | Toggle flash search |
| `<C-U>` | Insert | :help i_CTRL-U-default |
| `<C-W>` | Insert | :help i_CTRL-W-default |
| `<C-W><C-D>` | Normal | Show diagnostics under the cursor |
| `<C-W>d` | Normal | Show diagnostics under the cursor |
| `<Esc>` | Normal | Clear search highlight |
| `<M-i>` | Insert | Pick icon (insert) |
| `<S-Tab>` | Insert | vim.snippet.jump if active, otherwise <S-Tab> |
| `<Tab>` | Insert | vim.snippet.jump if active, otherwise <Tab> |
| `@` | Visual | :help v_@-default |
| `Q` | Visual | :help v_Q-default |
| `S` | Normal | Flash treesitter |
| `Y` | Normal | :help Y-default |
| `[<C-L>` | Normal | :lpfile |
| `[<C-Q>` | Normal | :cpfile |
| `[<C-T>` | Normal | :ptprevious |
| `[<leader>` | Normal | Add empty line above cursor |
| `[A` | Normal | :rewind |
| `[B` | Normal | :brewind |
| `[D` | Normal | Jump to the first diagnostic in the current buffer |
| `[L` | Normal | :lrewind |
| `[Q` | Normal | :crewind |
| `[T` | Normal | :trewind |
| `[a` | Normal | :previous |
| `[b` | Normal | Previous buffer |
| `[d` | Normal | Jump to the previous diagnostic in the current buffer |
| `[l` | Normal | :lprevious |
| `[n` | Visual | Select previous node |
| `[q` | Normal | Previous quickfix |
| `[t` | Normal | Prev TODO |
| `]<C-L>` | Normal | :lnfile |
| `]<C-Q>` | Normal | :cnfile |
| `]<C-T>` | Normal | :ptnext |
| `]<leader>` | Normal | Add empty line below cursor |
| `]A` | Normal | :last |
| `]B` | Normal | :blast |
| `]D` | Normal | Jump to the last diagnostic in the current buffer |
| `]L` | Normal | :llast |
| `]Q` | Normal | :clast |
| `]T` | Normal | :tlast |
| `]a` | Normal | :next |
| `]b` | Normal | Next buffer |
| `]d` | Normal | Jump to the next diagnostic in the current buffer |
| `]l` | Normal | :lnext |
| `]n` | Visual | Select next node |
| `]q` | Normal | Next quickfix |
| `]t` | Normal | Next TODO |
| `an` | Visual | Select parent (outer) node |
| `gA` | Normal | Align with preview |
| `gO` | Normal | vim.lsp.buf.document_symbol() |
| `ga` | Normal | Align |
| `gc` | Operator | Comment textobject |
| `gc` | Normal | Toggle comment |
| `gcc` | Normal | Toggle comment line |
| `gra` | Normal | vim.lsp.buf.code_action() |
| `gri` | Normal | vim.lsp.buf.implementation() |
| `grn` | Normal | vim.lsp.buf.rename() |
| `grr` | Normal | vim.lsp.buf.references() |
| `grt` | Normal | vim.lsp.buf.type_definition() |
| `grx` | Normal | vim.lsp.codelens.run() |
| `gx` | Normal | Opens filepath or URI under cursor with the system handler (file explorer, web browser, …) |
| `in` | Visual | Select child (inner) node |
| `r` | Operator | Remote flash |
| `s` | Normal | Flash jump |

## Git

| Key | Mode | Action |
|-----|------|--------|
| `<leader>gH` | Normal | Branch history |
| `<leader>gd` | Normal | Diffview open |
| `<leader>gf` | Normal | Fugitive status |
| `<leader>gg` | Normal | Lazygit |
| `<leader>gh` | Normal | File history |

## Harpoon

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ha` | Normal | Harpoon add |

## Icon

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ii` | Normal | Pick icon |
| `<leader>iy` | Normal | Yank icon |

## Leader (misc)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>0` | Normal | Dashboard |
| `<leader>?` | Normal | Random tip + search keymaps |
| `<leader>P` | Normal | Paste before from clipboard |
| `<leader>Y` | Normal | Yank line to clipboard |
| `<leader>d` | Normal | Delete to void |
| `<leader>n` | Normal | Find buffers |
| `<leader>p` | Normal | Paste from clipboard |
| `<leader>p` | Visual | Paste over without yank |
| `<leader>v` | Normal | Treesitter incremental select |

## Quit

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ql` | Normal | Load quickfix list |
| `<leader>qq` | Normal | Quit |
| `<leader>qs` | Normal | Save quickfix list |

## Search/Replace

| Key | Mode | Action |
|-----|------|--------|
| `<leader>sr` | Normal | Search and replace |
| `<leader>st` | Normal | TODO quickfix |
| `<leader>sv` | Normal | Source nvim config |
| `<leader>sw` | Normal | Search word under cursor |

## Test

| Key | Mode | Action |
|-----|------|--------|
| `<leader>tO` | Normal | Test: output panel |
| `<leader>tS` | Normal | Test: stop |
| `<leader>tf` | Normal | Test: file |
| `<leader>tj` | Normal | Insert Taskwarrior Jira tasks |
| `<leader>tl` | Normal | Test: last |
| `<leader>tn` | Normal | Test: nearest |
| `<leader>to` | Normal | Test: output |
| `<leader>ts` | Normal | Test: suite |
| `<leader>tt` | Normal | Test: summary |

## UI

| Key | Mode | Action |
|-----|------|--------|
| `<leader>uN` | Normal | Notification history |
| `<leader>un` | Normal | Dismiss notifications |

## Wiki/Write

| Key | Mode | Action |
|-----|------|--------|
| `<leader>w` | Normal | Write file |
| `<leader>wn` | Normal | Wiki open |
| `<leader>wt` | Normal | Wiki tags |
| `<leader>ww` | Normal | Wiki index |

## Yank

| Key | Mode | Action |
|-----|------|--------|
| `<leader>y` | Normal | Yank to clipboard |
| `<leader>yf` | Normal | Yank full path |
| `<leader>yn` | Normal | Yank filename |
| `<leader>yr` | Normal | Yank relative path |

