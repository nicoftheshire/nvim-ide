# nvim-ide spec

Label: wayfinder:map

## Destination

A written spec for **nvim-ide**: a personal terminal-based IDE built as a Neovim configuration. The spec covers the window/plugin architecture (Sidebar, terminal, git/diff/graph stack), the full keybinding scheme, the Project switcher and Session-persistence design, and cross-platform (macOS + Linux, no Windows) setup — detailed enough to be sliced into implementation tickets via a separate to-tickets step. The destination is the spec document itself, not the working build.

## Notes

- Domain: personal developer tooling (a Neovim-based terminal IDE for one user), not a product for others.
- Architecture decisions already locked are recorded as ADRs in `docs/adr/0001`-`0009` (0008-0009 added by ticket 05's grilling); vocabulary is in `GLOSSARY.md`. Read both before resolving any ticket below — they are settled, not open questions.
- Skills this effort leans on: `mattpocock-skills:research` for research tickets, `mattpocock-skills:prototype` for the prototype ticket, `mattpocock-skills:grilling` + `mattpocock-skills:domain-modeling` for grilling tickets.
- Standing constraints that apply across every ticket: the Startup Budget (<100ms cold start, excludes LSP attach — ADR-0007) and transportability (built on macOS, manually copied to a Linux box — no packaging, see Out of scope).
- No remote is configured for this repo yet, so research tickets capture findings on a local throwaway `research/<name>` branch (committed, not pushed) rather than the usual push-without-PR.

## Decisions so far

- [neo-tree dual-source sidebar research](issues/01-neo-tree-dual-source.md): confirmed — source-switching is built-in to neo-tree.nvim; but corrected ADR-0003 — the git_status-click-opens-diffview wiring is custom glue, not a shipped integration, and `git_status` shows all changed files (not unstaged-only), which narrowed the `Changes View` glossary definition.
- [LSP baseline language mappings research](issues/03-lsp-baseline-languages.md): Mason/lspconfig names confirmed for all five languages (`lua_ls`, `ts_ls`, `pyright`, `jdtls`, `terraformls`); jdtls needs materially more setup (nvim-jdtls plugin, per-project workspace, Java 21 runtime) — spec should scope baseline Java to bare-lspconfig only and defer debug/test tooling.
- [Cross-platform bootstrap research](issues/02-cross-platform-bootstrap.md): first launch is just `nvim` once (lazy.nvim's `install_missing()` honors `lazy-lock.json` automatically — never run `:Lazy sync` first, it overwrites the lockfile); treesitter parsers and Mason binaries self-install separately and are never synced between machines; bare Linux boxes usually lack a C compiler for treesitter, so install the portable `zig` binary rather than `build-essential` (see new task ticket 07).
- [Changes View empty/conflict-state research](issues/08-changes-view-empty-states.md): a clean working tree doesn't blank the `git_status` view or leave a stale list — it relabels the root row to "GIT STATUS (working tree clean) for \<path\>" with zero rows beneath; unresolved merge conflicts get a dedicated conflict icon/highlight (`NeoTreeGitConflict`), never falling through to a generic "modified" status. No documented empty-state glue pattern exists — `before_render` and the internal `type = "message"` node convention are the closest reusable precedents if custom glue is wanted.
- [Install macOS prerequisites](issues/04-install-prerequisites.md): done — Neovim 0.12.6, lazygit 0.66.3 installed via Homebrew (ripgrep already present); JetBrains Mono Nerd Font installed and set as ghostty's `font-family` (none was configured before), glyph rendering confirmed visually. Prototype ticket (06) is now unblocked on this front.
- [Keybinding scheme](issues/05-keybinding-scheme.md): full `<leader>`-prefixed mnemonic map settled (Sidebar/Terminal/Git groups plus a standalone Chrome Nav toggle). Reopened and changed the leader key from `<Space>` to `<C-j>` to mirror the user's tmux prefix (new ADR-0008), which also resolved the neo-tree `<space>` collision by construction. Added a persistent Project List panel beneath the Sidebar for one-keypress Project switching, replacing the originally-assumed fzf-lua picker for that one use case (new ADR-0009, clarifying addendum on ADR-0003, new `Project List panel` glossary term). Prototype ticket (06) is now fully unblocked.
- [Layout prototype](issues/06-layout-prototype.md): layout/interaction flow confirmed right, no structural rework needed. Surfaced and fixed real gaps: an undiscoverable Project List panel close key (fixed with an in-panel hint, not a key change), a missing open-files tab bar (`bufferline.nvim`, added a `<leader>b` buffer group as an addendum to ticket 05), and a missing quit-all key (`<leader>qq`, also added to ticket 05). Confirmed the live-per-line-diff-gutter ask is already covered by ADR-0006's `gitsigns.nvim` — no new decision needed, just wired in and verified. Prototype asset: `prototype/layout-skeleton` branch (not merged).

## Not yet specified

(no open fog right now — the frontier covers everything currently specifiable toward the destination)

## Out of scope

- Dedicated coding-agent section/pane: originally requested, dropped during charting — agent CLIs are run directly in the general-purpose terminal instead.
- Windows support: explicitly excluded by the user from the start.
- Proper packaging/distribution (installer script, one-command setup): explicitly deferred by the user ("I'll worry about proper packaging later") — this effort only needs manual-copy transportability.
