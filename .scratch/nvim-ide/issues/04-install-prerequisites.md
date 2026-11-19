Type: task
Status: resolved

## Question

Nothing to decide here: the macOS dev machine has no Neovim installed yet and needs the external prerequisites nvim-ide's spec assumes are present before the Prototype ticket can build anything real to react to.

Install on this macOS machine (via Homebrew, confirming each with the user before running):
- Neovim (a recent stable release that supports the plugins named in the ADRs)
- `lazygit` (embedded for the repo-graph view, ADR-0006)
- `ripgrep` (required by fzf-lua / general grep-based pickers)
- A Nerd Font, if one isn't already active in the terminal (needed for neo-tree/lualine icons)

Verify each with its version command (`nvim --version`, `lazygit --version`, `rg --version`) and confirm the terminal in use renders Nerd Font glyphs.

## Answer

Installed via Homebrew: Neovim 0.12.6, lazygit 0.66.3. `ripgrep` 14.1.1 was already present, no action needed. Installed the `font-jetbrains-mono-nerd-font` cask (ghostty had no explicit `font-family` set before this) and set `font-family = "JetBrainsMono Nerd Font Mono"` in `~/.config/ghostty/config`. Confirmed rendering by printing a line of sample Nerd Font glyphs (folder, git-branch, file, lua, check icons) directly to the terminal after a ghostty reload — user confirmed all icons rendered correctly, no boxes/blanks/placeholders.
