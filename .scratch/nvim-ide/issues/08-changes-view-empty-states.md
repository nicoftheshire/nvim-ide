Type: research
Status: resolved

## Question

Ticket 01 confirmed neo-tree's `git_status` source lists all changed files (staged + unstaged + untracked) with per-file status icons, but didn't cover what it renders when there's nothing to show it, or when the repo is mid-merge-conflict.

Verify against current neo-tree.nvim documentation/source:
- What does the `git_status` source render when there are zero changed files — an empty window, a placeholder message, or does neo-tree keep showing the last-known list?
- Does the `git_status` source have any conflict-aware rendering (e.g. a distinct icon/status for files with unresolved merge conflicts), or does it just show conflicted files as "modified" like any other changed file?
- Is there a documented or common custom-glue pattern (e.g. an empty-state message component, or a check before opening the source) worth citing for the spec, given ticket 01 already found this source's wiring leans on custom glue rather than built-ins?

Report findings with enough detail (exact behavior, any config keys) that the spec's Changes View section can state the empty-state and conflict-state behavior directly, and flag anything that should further narrow the `Changes View` glossary definition.

## Answer

Confirmed against current neo-tree.nvim source (`main` branch, fetched 2026-11-19): with zero changed files, `git_status` does **not** blank the window and does **not** retain a stale last-known list — `M.get_git_status` (`lua/neo-tree/sources/git_status/lib/items.lua`) recomputes `git.status(...)` fresh on every navigate/refresh, and with no changes the root node simply gets no children. The root node's own label is dynamically swapped (`lua/neo-tree/sources/git_status/components.lua`) from `"GIT STATUS for <path>"` to `"GIT STATUS (working tree clean) for <path>"` based on `node:has_children()`. So the actual UX is one header row reading "(working tree clean)" with nothing beneath it — not a dedicated "No changes" placeholder node. (The vimdoc's "this view will be empty" wording is a simplification of this behavior, worth noting if cited verbatim.)

Merge conflicts get distinct, dedicated rendering, not a plain "modified" fallback. The shared `git_status` component (`lua/neo-tree/sources/common/components.lua`, used by both `filesystem` and `git_status`) classifies each two-character porcelain code via `git_parser.status_code_is_conflict(x, y)` (`lua/neo-tree/git/parser.lua`), which flags `UU`, `AA`, `DD`, `AU`, `UA`, `DU`, `UD`. Conflicted entries get a dedicated `conflict` symbol (`` by default) and a dedicated `NeoTreeGitConflict` highlight group, and are explicitly excluded from also being tagged generic "modified" — this is shared plumbing, so `git_status` gets it automatically, not as something it opts into separately.

No documented or community-demonstrated custom-glue pattern exists specifically for the empty-changes-view case (checked vimdoc, project Wiki Recipes/Behaviors pages, GitHub issue search — not found as of 2026-11-19). Two in-repo precedents are worth citing as building blocks if the spec wants a more prominent empty-state treatment than the default header relabel: the documented `before_render` event (already wired per-source, a natural hook for inspecting an empty tree before it draws), and the internal `type = "message"` node convention used elsewhere (e.g. "(N hidden items)" rows) — `git_status`'s own component already defensively handles `node.type == "message"` even though its built-in empty state doesn't use it. Neither is ready-made; either would be custom glue in the same spirit as the already-planned diffview `<cr>` override.

No further narrowing of the `Changes View` glossary definition is needed — the existing definition already covers "lists changed files"; the empty/clean state and conflict rendering are implementation details for the spec's Changes View section, not vocabulary changes.

Full findings (citations, exact source excerpts, URLs): `.scratch/nvim-ide/research/08-changes-view-empty-states.md` on the (unmerged, local-only) `research/changes-view-empty-states` branch.
