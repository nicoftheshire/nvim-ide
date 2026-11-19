Type: task
Status: open

## Question

Nothing to decide here: the macOS dev machine has no Neovim installed yet and needs the external prerequisites nvim-ide's spec assumes are present before the Prototype ticket can build anything real to react to.

Install on this macOS machine (via Homebrew, confirming each with the user before running):
- Neovim (a recent stable release that supports the plugins named in the ADRs)
- `lazygit` (embedded for the repo-graph view, ADR-0006)
- `ripgrep` (required by fzf-lua / general grep-based pickers)
- A Nerd Font, if one isn't already active in the terminal (needed for neo-tree/lualine icons)

Verify each with its version command (`nvim --version`, `lazygit --version`, `rg --version`) and confirm the terminal in use renders Nerd Font glyphs.

## Answer

(record what was installed, versions, and the font/terminal confirmation here when done)
