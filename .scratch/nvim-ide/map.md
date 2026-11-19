# nvim-ide spec

Label: wayfinder:map

## Destination

A written spec for **nvim-ide**: a personal terminal-based IDE built as a Neovim configuration. The spec covers the window/plugin architecture (Sidebar, terminal, git/diff/graph stack), the full keybinding scheme, the Project switcher and Session-persistence design, and cross-platform (macOS + Linux, no Windows) setup — detailed enough to be sliced into implementation tickets via a separate to-tickets step. The destination is the spec document itself, not the working build.

## Notes

- Domain: personal developer tooling (a Neovim-based terminal IDE for one user), not a product for others.
- Architecture decisions already locked during charting are recorded as ADRs in `docs/adr/0001`-`0007`; vocabulary is in `GLOSSARY.md`. Read both before resolving any ticket below — they are settled, not open questions.
- Skills this effort leans on: `mattpocock-skills:research` for research tickets, `mattpocock-skills:prototype` for the prototype ticket, `mattpocock-skills:grilling` + `mattpocock-skills:domain-modeling` for grilling tickets.
- Standing constraints that apply across every ticket: the Startup Budget (<100ms cold start, excludes LSP attach — ADR-0007) and transportability (built on macOS, manually copied to a Linux box — no packaging, see Out of scope).
- No remote is configured for this repo yet, so research tickets capture findings on a local throwaway `research/<name>` branch (committed, not pushed) rather than the usual push-without-PR.

## Decisions so far

- [neo-tree dual-source sidebar research](issues/01-neo-tree-dual-source.md): confirmed — source-switching is built-in to neo-tree.nvim; but corrected ADR-0003 — the git_status-click-opens-diffview wiring is custom glue, not a shipped integration, and `git_status` shows all changed files (not unstaged-only), which narrowed the `Changes View` glossary definition.
- [LSP baseline language mappings research](issues/03-lsp-baseline-languages.md): Mason/lspconfig names confirmed for all five languages (`lua_ls`, `ts_ls`, `pyright`, `jdtls`, `terraformls`); jdtls needs materially more setup (nvim-jdtls plugin, per-project workspace, Java 21 runtime) — spec should scope baseline Java to bare-lspconfig only and defer debug/test tooling.
- [Cross-platform bootstrap research](issues/02-cross-platform-bootstrap.md): first launch is just `nvim` once (lazy.nvim's `install_missing()` honors `lazy-lock.json` automatically — never run `:Lazy sync` first, it overwrites the lockfile); treesitter parsers and Mason binaries self-install separately and are never synced between machines; bare Linux boxes usually lack a C compiler for treesitter, so install the portable `zig` binary rather than `build-essential` (see new task ticket 07).

## Not yet specified

- Whether Chrome Navigation Mode's window/pane-navigation keys should mirror the user's existing `~/.tmux.conf` bindings for muscle-memory consistency — not raised yet; sharpness depends on how much tmux is used alongside nvim-ide day to day.
- True empty-state behavior of the Changes View (zero changed files, merge-conflict state) — ticket 01 confirmed `git_status` shows all changed files with status icons and no unstaged-only filter, but didn't cover what renders when there's nothing to show or a conflict is active.

## Out of scope

- Dedicated coding-agent section/pane: originally requested, dropped during charting — agent CLIs are run directly in the general-purpose terminal instead.
- Windows support: explicitly excluded by the user from the start.
- Proper packaging/distribution (installer script, one-command setup): explicitly deferred by the user ("I'll worry about proper packaging later") — this effort only needs manual-copy transportability.
