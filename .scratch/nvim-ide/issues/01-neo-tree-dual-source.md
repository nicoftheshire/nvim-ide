Type: research
Status: resolved

## Question

ADR-0003 assumes `neo-tree.nvim` can anchor the Sidebar as a single slot that toggles between a `filesystem` source (Tree View) and a `git_status` source (Changes View) using neo-tree's own built-in source-switch mechanism, and that selecting a file in the `git_status` source can be wired to open it in `diffview.nvim`.

Verify against current neo-tree.nvim documentation/source:
- Does neo-tree actually support switching sources (`filesystem` ↔ `git_status`) within one persistent window instance, and what's the actual command/keymap for it (e.g. a `source_selector` component, or a command like `:Neotree source=git_status`)?
- What does the `git_status` source show for each entry — does it already compute "unstaged changes" specifically (vs staged, vs untracked), and is that distinction visible/filterable?
- What's the supported way to hook "selecting a file in git_status source" to open `diffview.nvim` instead of neo-tree's default file-open behavior? Is this a documented integration point or does it require custom Lua in an `event_handlers`/mapping override?
- Any known current limitations or maintenance-status concerns worth flagging before this becomes a locked spec decision.

Report findings with enough detail (exact config keys, command names) that the spec can cite them directly, and flag anything that contradicts ADR-0003's premise.

## Answer

Confirmed: neo-tree.nvim's source-switching is built-in and documented — `:Neotree action=focus source=<filesystem|git_status> position=left` (or the `source_selector` winbar widget) swaps the same persistent sidebar window's content, exactly as ADR-0003 assumes. Partially contradicted: the diffview.nvim hook is *not* a first-class, shipped integration in either plugin — it's achievable only via custom Lua glue (overriding `git_status.window.mappings["<cr>"]` with a `commands` entry that calls `:DiffviewOpen -- <path>`), so the ADR/spec should describe it as custom glue to build and maintain, not a built-in feature. New nuance: the `git_status` source shows *all* changed files (staged + unstaged + untracked) in one list with per-file stage icons, with no built-in filter for "unstaged only" — an open upstream issue (#1031) even flags the underlying data shape as due for a rework — so "Changes View" as unstaged-only will need either a loosened definition or custom filtering. The project is actively maintained, but `git_status`/`<cr>`-mapping behavior has a history of regressions during filesystem-focused refactors, so pin a specific neo-tree version.

Full findings (citations, exact config): `.scratch/nvim-ide/research/01-neo-tree-dual-source.md` on the (unmerged, local-only) `research/neo-tree-dual-source` branch.
