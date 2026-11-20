Type: grilling
Status: resolved
Blocked by: 01

## Question

Charting settled the leader key (`<Space>`) and that `which-key.nvim` provides discoverability, but not the actual keymap scheme itself. Define the complete `<leader>`-prefixed mnemonic map covering at least:

- Toggling the Sidebar open/closed
- Switching the Sidebar's source between Tree View and Changes View
- Opening the diff viewer from a Changes View selection (if not just `<CR>`)
- Toggling the bottom terminal, and opening additional numbered terminals
- Opening the `lazygit` graph float
- Opening the Project switcher (fzf-lua picker) — note the original ask wants this toggleable in the bottom-left specifically, which may mean a persistent small status element plus a keymap to open the picker, not just the keymap alone
- Removing a Project from the Known Projects List
- Toggling Chrome Navigation Mode on/off

Also decide how to avoid collisions with neo-tree's own default keymaps once ticket 01 (neo-tree dual-source research) reports what those are.

Also decide, specifically for the Chrome Navigation Mode window/pane-navigation keys: should they mirror the user's existing `~/.tmux.conf` bindings for muscle-memory consistency, or follow their own independent scheme? Ask how much tmux is actually used alongside nvim-ide day to day before deciding.

## Answer

The leader key changed from `<Space>` to `<C-j>` (see ADR-0008) to mirror the user's tmux prefix, which also resolved the neo-tree `<space>`→`toggle_node` collision by construction — no leftover `<space>` combos to avoid. nvim-ide runs as the top-level terminal app locally (no tmux nesting, which would otherwise swallow `<C-j>` at the multiplexer level); the Linux box reached over SSH (ticket 07) wraps it in a vanilla, stock-prefix tmux session purely for disconnect resilience, avoiding any collision there too. Vim-style window navigation (Chrome Navigation Mode) is `<leader>` then `h`/`j`/`k`/`l`, mirroring the tmux prefix+hjkl gesture directly.

Final scheme:

- **Leader**: `<C-j>`
- **Window navigation (vim-style Chrome Navigation Mode)**: `<leader>` then `h`/`j`/`k`/`l`
- **`<leader>s` — Sidebar group**:
  - `ss` — toggle Sidebar open/closed
  - `sv` — switch Sidebar view (Tree View ↔ Changes View)
  - `sp` — focus the Project List panel (then `j`/`k` to navigate, `<cr>` to switch to that Project, `x` to remove it from the Known Projects List)
- **`<leader>t` — Terminal group**:
  - `tt` — toggle/return to the last-focused terminal
  - `t1`–`t4` — four quick-access numbered terminal slots
  - `tn` — prompt for an arbitrary terminal number beyond 4
- **`<leader>g` — Git group**:
  - `gg` — open the lazygit float
  - `gs` — open neogit (stage/commit) — not in the ticket's original list, added since ADR-0006 locks neogit into the git stack
  - No separate diff-viewer key: Changes View's own `<cr>` already opens diffview per ticket 01's glue
- **`<leader>cn`** — toggle Chrome Navigation Mode (standalone leaf, not a group)

Scope change: the Project switcher is no longer the fzf-lua picker originally implied by charting — it's the new, always-visible Project List panel (see ADR-0009), reached via `<leader>sp`. fzf-lua remains the picker library for everything else (file search, LSP references) per ADR-0004.

Recorded via the domain-modeling pass: ADR-0008 (leader key), ADR-0009 (Project List panel split from the Sidebar), a clarifying addendum on ADR-0003, and GLOSSARY.md updates (narrowed `Sidebar` definition, new `Project List panel` term).
