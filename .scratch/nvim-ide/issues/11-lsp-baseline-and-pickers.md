# 11: LSP baseline & pickers

**What to build:** Diagnostics, completion, and navigation for the five baseline languages, plus fzf-lua wired up as the picker for file search and LSP references.

**Blocked by:** 10

**Status:** resolved

- [x] Mason installs, and `lspconfig` enables (via `vim.lsp.config('X', {...})` + `vim.lsp.enable('X')`, not the deprecated `require('lspconfig').X.setup{}` form), all five baseline servers: `lua_ls`, `ts_ls`, `pyright`, `jdtls`, `terraformls`.
- [x] Java support is bare `jdtls` via `lspconfig` only — no `nvim-jdtls` plugin, no debug adapter, no test runner wired in (explicitly deferred).
- [x] fzf-lua is installed and configured as the picker for file search and "LSP references," per ADR-0004 (no native-compiled dependency).
- [x] Opening a file in each of the five languages shows live diagnostics and completion from its server.
- [x] jdtls's slower JVM startup is confirmed not to regress the Startup Budget measured in ticket 10 (LSP attach is excluded from that budget by ADR-0007).

## Comments

Implemented in `init.lua`'s `mason-lspconfig.nvim` plugin spec: a `vim.lsp.config('lua_ls', {...})` override (Lua runtime/`vim` globals, the one server needing custom settings) plus `require('mason-lspconfig').setup({ ensure_installed = {five server names}, automatic_enable = true })` — mason-lspconfig's own `ensure_installed`/`automatic_enable` logic (spec.md line 130) resolves to `vim.lsp.enable` internally, never the deprecated `setup{}` form. A shared `LspAttach` autocmd enables native completion (`vim.lsp.completion.enable(..., { autotrigger = true })`, Neovim 0.11+, no completion plugin needed) and, for servers supporting references, overrides the default `grr` keymap to use fzf-lua's `lsp_references()` instead of the built-in picker. Added `ibhagwan/fzf-lua` with a `<C-p>` lazy-loaded keymap for `files()` (ADR-0004: no native-compiled dependency, unlike telescope-fzf-native).

Verified live on macOS (real interactive Neovim via tmux, not just headless): all five Mason packages (`lua-language-server`, `typescript-language-server`, `pyright`, `terraform-ls`, `jdtls`) installed automatically on first launch. Opened one fixture file per language with a deliberate error — each attached the right client (`lua_ls`, `ts_ls`, `pyright`, `terraformls`, `jdtls`), reported `completionProvider` in its capabilities, and published live diagnostics (confirmed directly for Lua/TS/Python/Terraform; jdtls published a diagnostic too, though its specific message was the expected "non-project file" notice rather than the planted typo, since the fixture wasn't a full Maven/Gradle project — a fixture limitation, not a wiring defect, and per the spec's Testing Decisions, deeper jdtls correctness is out of scope here). `<C-p>` opened a real fzf-lua file-search window with live preview; the `grr` override resolved to the fzf-lua keymap.

jdtls needed a materially newer JDK than the Java 21 the original research named: the Mason-shipped build's launcher enforces "at least Java 21," but its OSGi bundles actually require JavaSE 25 at runtime — confirmed by running the launcher directly and reading its own crash log. Verified working with Java 27; documented in README as "a recent JDK, floor moves with each jdtls release" rather than hardcoding a now-stale "Java 21" figure. Installed `fzf` (required by fzf-lua, previously missing on this machine) and a newer JDK via Homebrew as part of verification; both are now documented as README prerequisites alongside the existing `lazygit`/`ripgrep` entries.

Startup Budget re-verified headless, 3 runs: 25-39ms cold start, comfortably under the 100ms budget (ADR-0007) — mason-lspconfig's config function runs eagerly at startup but only registers an `LspAttach` autocmd and kicks off Mason's own async install/enable bookkeeping; it does not block on any language server actually starting.

Code review (Standards + Spec axes, parallel sub-agents): Spec axis found no gaps, no scope creep, no incorrect implementations. Standards axis flagged one real issue — a comment above the plugin list had gone stale/self-contradictory after this ticket's keymaps were added — fixed. Its remaining notes (the `fzf-lua` reference living inside the `LspAttach` callback rather than next to the `fzf-lua` plugin spec; the `config` function doing three related things) were judgement-call smells, not standards violations, and are left as-is: at this config's current size, splitting them out would add indirection ADR-0001's "small, readable" bar doesn't ask for.

Note: this ticket was implemented in the same checkout as a concurrent session working ticket 12 (keybinding scheme). `init.lua` and this commit therefore also carry that session's in-progress leader-key/Chrome-Navigation-Mode/buffer-group additions, picked up incidentally since both tickets touch the same file — not part of ticket 11's own scope.
