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

(none yet — charting-phase decisions live in `GLOSSARY.md` and `docs/adr/`, not here)

## Not yet specified

- Whether Chrome Navigation Mode's window/pane-navigation keys should mirror the user's existing `~/.tmux.conf` bindings for muscle-memory consistency — not raised yet; sharpness depends on how much tmux is used alongside nvim-ide day to day.
- Exact empty/edge-case behavior of the Changes View (no unstaged changes, merge conflicts, untracked-only files) — depends on what the neo-tree `git_status` research below finds is actually possible.

## Out of scope

- Dedicated coding-agent section/pane: originally requested, dropped during charting — agent CLIs are run directly in the general-purpose terminal instead.
- Windows support: explicitly excluded by the user from the start.
- Proper packaging/distribution (installer script, one-command setup): explicitly deferred by the user ("I'll worry about proper packaging later") — this effort only needs manual-copy transportability.
