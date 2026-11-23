Type: task
Status: resolved

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

Provisioned on Red Hat Enterprise Linux 8.10: Neovim 0.13.0, lazygit 0.66.3, ripgrep 16.0.0, `zig` 0.17.1 (per ticket 02's treesitter-compiler-fallback finding). `NVIM_APPNAME=nvim-ide` exported in both `~/.bashrc` and `~/.bash_profile` on that box — SSH opens a login shell, which reads `~/.bash_profile` (or `~/.profile`), not `~/.bashrc`; any shell opened after login (new tmux pane, etc.) reads `~/.bashrc` instead, so both needed the export to cover both cases. Repo cloned to `~/.config/nvim-ide`. No RHEL-specific gotchas surfaced.

This machine is reached over SSH from a Windows VDI, using PowerShell as the SSH client — glyph rendering for the Nerd Font requirement happens client-side on that Windows machine, not on the Linux box itself (SSH only streams text). The current VDI is Windows 10 without Windows Terminal available, and is about to be replaced by a newly-provisioned Windows 11 VDI, so any font configuration done on it now would be lost. Deferred to [ticket 09](09-windows-vdi-nerd-font.md) rather than configured here.
