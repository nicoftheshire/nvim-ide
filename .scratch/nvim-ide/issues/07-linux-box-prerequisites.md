Type: task
Status: open

## Question

Nothing to decide here: ticket 02's research found that a bare Linux box typically lacks a C compiler, which `nvim-treesitter` needs to compile parsers on first launch (macOS has one by default via Xcode CLT; Linux usually doesn't until `build-essential` or equivalent is installed). The research recommended installing a standalone `zig` binary instead — it's the last entry in treesitter's compiler-fallback list and needs no package-manager provisioning, which fits this repo's transportability goal better than a distro-specific `build-essential` install.

Whenever the Linux machine (the one reached over SSH) is available for this effort, provision it with:
- Neovim (matching the version used on macOS)
- `lazygit`, `ripgrep`
- `zig` (for treesitter parser compilation — see ticket 02's answer)
- A Nerd Font active in whatever terminal is used to SSH in
- `NVIM_APPNAME=nvim-ide` exported in that machine's shell profile
- The repo cloned/symlinked to `~/.config/nvim-ide`

This is a HITL task since it requires an active SSH session to that machine, which this session doesn't have.

## Answer

(record what was installed, versions, and any distro-specific gotchas encountered here when done)
