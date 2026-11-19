Type: research
Status: open

## Question

ADR-0003 assumes `neo-tree.nvim` can anchor the Sidebar as a single slot that toggles between a `filesystem` source (Tree View) and a `git_status` source (Changes View) using neo-tree's own built-in source-switch mechanism, and that selecting a file in the `git_status` source can be wired to open it in `diffview.nvim`.

Verify against current neo-tree.nvim documentation/source:
- Does neo-tree actually support switching sources (`filesystem` ↔ `git_status`) within one persistent window instance, and what's the actual command/keymap for it (e.g. a `source_selector` component, or a command like `:Neotree source=git_status`)?
- What does the `git_status` source show for each entry — does it already compute "unstaged changes" specifically (vs staged, vs untracked), and is that distinction visible/filterable?
- What's the supported way to hook "selecting a file in git_status source" to open `diffview.nvim` instead of neo-tree's default file-open behavior? Is this a documented integration point or does it require custom Lua in an `event_handlers`/mapping override?
- Any known current limitations or maintenance-status concerns worth flagging before this becomes a locked spec decision.

Report findings with enough detail (exact config keys, command names) that the spec can cite them directly, and flag anything that contradicts ADR-0003's premise.
