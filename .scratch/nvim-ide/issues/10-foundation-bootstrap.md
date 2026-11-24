# 10: Foundation & cross-platform bootstrap

**What to build:** A kickstart.nvim-style minimal Neovim config, isolated under `NVIM_APPNAME=nvim-ide`, that starts fast and brings itself up to a working state with zero manual commands on a brand-new machine — macOS or the Linux box reached over SSH.

**Blocked by:** None (can start immediately)

**Status:** resolved

- [x] `init.lua` follows the kickstart.nvim style (small, readable, no opinionated UI baked in) per ADR-0001, and runs correctly under `NVIM_APPNAME=nvim-ide` (ADR-0002) without claiming the default `~/.config/nvim` slot.
- [x] lazy.nvim is the plugin manager, with a committed `lazy-lock.json`. A fresh clone followed by exporting `NVIM_APPNAME=nvim-ide` and running `nvim` once installs all missing plugins at the exact locked commits, with no `:Lazy sync`/`:Lazy install`/`:Lazy restore` required or run.
- [x] nvim-treesitter is pinned to `branch = "master"`, configured with `ensure_installed`/`auto_install` and a `build = ':TSUpdate'` hook; parser compilation succeeds on the Linux box via the `zig` fallback with no C compiler installed.
- [x] Mason and mason-lspconfig are installed and wired (core plumbing only — no specific language servers yet; that's ticket 11).
- [x] which-key.nvim is installed with a base config (no leader-group content yet; that's ticket 12).
- [x] `nvim --startuptime` confirms cold start stays under 100ms, excluding any LSP client attach time (ADR-0007, the Startup Budget).
- [x] The full first-launch procedure (clone/symlink to `~/.config/nvim-ide`, export `NVIM_APPNAME=nvim-ide`, run `nvim` once) is verified working on both macOS and the already-provisioned RHEL box.

## Comments

Implemented `init.lua` at the repo root (lazy.nvim bootstrap, nvim-treesitter pinned to `master` with `ensure_installed`/`auto_install`/`build = ':TSUpdate'`, `mason-org/mason.nvim` + `mason-org/mason-lspconfig.nvim` + `neovim/nvim-lspconfig` as plumbing only, `which-key.nvim` with an empty base config) plus a `README.md` documenting the first-launch procedure. Committed `lazy-lock.json` generated from a real install.

Verified on macOS:
- Symlinked this checkout to `~/.config/nvim-ide` and ran a real first launch under `NVIM_APPNAME=nvim-ide`; `~/.config/nvim` (the default, unrelated plain-Neovim slot) was untouched (its `lazy-lock.json` mtime didn't change).
- Simulated a genuinely fresh clone in an isolated sandbox (its own `XDG_*` dirs): a single plain `nvim --headless +qa` — no `:Lazy` command of any kind — installed all five managed plugins at exactly the commits pinned in `lazy-lock.json`, and `ensure_installed` treesitter parsers (lua, vim, vimdoc, query, markdown, markdown_inline) compiled successfully using the `cc` toolchain (macOS's Xcode CLT fallback in the `$CC`/`cc`/`gcc`/`clang`/`cl`/`zig` order — consistent with the Linux box needing the `zig` fallback instead, per ticket 02/07's findings).
- `nvim --startuptime`, 3 runs, headless, no LSP configured yet: ~17-25ms cold start — comfortably under the 100ms Startup Budget (ADR-0007).
- `:checkhealth` across lazy/mason/nvim-treesitter/which-key: no blocking errors — only expected warnings for optional language toolchains (Go, PHP, Julia, `wget`, `luarocks`) Mason doesn't need for this project's five languages, and treesitter's own "no healthcheck for which-key" (which-key doesn't ship one).

Code review flagged `vim.opt.clipboard = "unnamedplus"` as a synchronous option set during startup; fixed by deferring it with `vim.schedule(...)`, matching upstream kickstart.nvim's own precaution against a slow clipboard-provider probe eating into the Startup Budget. Re-verified startup time (still ~15-44ms) and that the option is applied correctly once the event loop ticks.

Verified on the RHEL box (user, via their own SSH session — pulled this commit into the already-cloned `~/.config/nvim-ide` per ticket 07, launched plain `nvim` with `NVIM_APPNAME=nvim-ide` already set in the shell): plugins installed automatically, line numbers/sign column confirmed `init.lua` loaded (no visible plugin UI is expected — ticket 10 adds none, that's tickets 11-14), `:Lazy` showed all 6 entries installed with no errors, and `nvim --startuptime` came in under the 100ms Startup Budget. Ticket resolved.
