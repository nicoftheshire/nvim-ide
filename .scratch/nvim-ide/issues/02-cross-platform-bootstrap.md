Type: research
Status: open

## Question

The spec needs an exact "first launch on a new machine" procedure for nvim-ide's transportability (ADR-0002, ADR-0004): clone/symlink the repo to `~/.config/nvim-ide`, set `NVIM_APPNAME=nvim-ide` in the shell profile, then bring plugins and compiled artifacts up on that specific OS.

Verify against current lazy.nvim, nvim-treesitter, and mason.nvim documentation/behavior:
- What's the exact sequence of commands (or autocmds to wire up) that take a freshly-cloned config with a committed `lazy-lock.json` to a fully working state on a machine that has never run it before — plugin install, treesitter parser compilation, Mason-managed LSP binary installation?
- Confirm (or correct) the claim that `lazy-lock.json` pins plugin versions portably across macOS/Linux, while treesitter parsers and Mason binaries are compiled/downloaded per-OS and must not be synced directly between machines — is there a cleaner current pattern (e.g. `MasonInstallAll` convenience command, lazy.nvim's own `build` step hooks) that automates this on first launch rather than requiring manual commands?
- Any current gotchas specific to running the same lazy.nvim-based config on macOS (Apple Silicon) vs Linux (the kind of Linux distro likely on an SSH'd-into dev box) — e.g. differing `cc`/compiler availability needed for treesitter's parser compilation step.

Report the exact command sequence and any autocmd/config snippet needed, so the spec's setup section can be written directly from it.
