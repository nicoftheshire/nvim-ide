Type: research
Status: resolved

## Question

The spec needs an exact "first launch on a new machine" procedure for nvim-ide's transportability (ADR-0002, ADR-0004): clone/symlink the repo to `~/.config/nvim-ide`, set `NVIM_APPNAME=nvim-ide` in the shell profile, then bring plugins and compiled artifacts up on that specific OS.

Verify against current lazy.nvim, nvim-treesitter, and mason.nvim documentation/behavior:
- What's the exact sequence of commands (or autocmds to wire up) that take a freshly-cloned config with a committed `lazy-lock.json` to a fully working state on a machine that has never run it before — plugin install, treesitter parser compilation, Mason-managed LSP binary installation?
- Confirm (or correct) the claim that `lazy-lock.json` pins plugin versions portably across macOS/Linux, while treesitter parsers and Mason binaries are compiled/downloaded per-OS and must not be synced directly between machines — is there a cleaner current pattern (e.g. `MasonInstallAll` convenience command, lazy.nvim's own `build` step hooks) that automates this on first launch rather than requiring manual commands?
- Any current gotchas specific to running the same lazy.nvim-based config on macOS (Apple Silicon) vs Linux (the kind of Linux distro likely on an SSH'd-into dev box) — e.g. differing `cc`/compiler availability needed for treesitter's parser compilation step.

Report the exact command sequence and any autocmd/config snippet needed, so the spec's setup section can be written directly from it.

## Answer

First launch on a new machine is just: clone/symlink the repo to `~/.config/nvim-ide`, export `NVIM_APPNAME=nvim-ide`, then run `nvim` once — no `:Lazy sync`/`:Lazy restore` needed. Launching Neovim triggers lazy.nvim's built-in `install_missing()` path (`install.missing = true` by default), which clones any missing plugin and checks it out to the exact commit recorded in `lazy-lock.json` automatically; `:Lazy sync`/`:Lazy install` must *not* be run first on a fresh clone, since neither respects the lockfile and both will silently overwrite it with latest commits. Treesitter parsers (pin nvim-treesitter to `branch = "master"`, not `main`, for Neovim 0.10/0.11 compatibility and the declarative `ensure_installed`/`auto_install` API) and Mason LSP binaries (via mason-lspconfig's `ensure_installed` + `automatic_enable`) self-install on that same first launch with zero manual commands — but through two different mechanisms: treesitter via lazy.nvim's `build = ':TSUpdate'` hook, Mason via the companion plugin's own startup-time logic, not lazy.nvim's `build` field. `lazy-lock.json` is pure git `{branch, commit}` data and is genuinely OS-agnostic; treesitter's compiled `parser.so` files and Mason's downloaded LSP binaries are native/OS-arch-specific artifacts under `stdpath("data")` and must never be synced between the macOS and Linux boxes — each machine compiles/downloads its own. The one real cross-platform gotcha: treesitter's parser compile step needs a C compiler (tried in order `$CC`, `cc`, `gcc`, `clang`, `cl`, `zig`) which is present by default on macOS via Xcode CLT but typically absent on a bare Linux box until `build-essential` (or distro equivalent) is installed — installing a standalone `zig` binary (last in that fallback list, a single portable binary with no package-manager provisioning needed) is the fix most aligned with this repo's transportability goal.

Full findings, citations, and the exact bootstrap/config snippets live in `.scratch/nvim-ide/research/02-cross-platform-bootstrap-findings.md` on the (unmerged, local-only) `research/cross-platform-bootstrap` branch.
