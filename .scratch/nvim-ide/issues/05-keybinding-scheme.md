Type: grilling
Status: open
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
