Type: prototype
Status: resolved
Blocked by: 01, 04, 05

## Question

Before locking the spec's layout and interaction section, build a rough, throwaway skeleton of nvim-ide's core shell to react to: the Sidebar (neo-tree dual-source toggle per ticket 01's findings) with a stub Project List panel beneath it (per ADR-0009 — this replaces the originally-planned fzf-lua Project switcher), the bottom toggleterm terminal, and the Chrome Navigation Mode toggle, wired with the keybinding scheme from ticket 05 (leader `<C-j>`, per ADR-0008). Not polished, not the real build — just enough to answer "does this actual layout and interaction flow feel right," and surface anything the grilled decisions missed once it's real instead of hypothetical.

## Answer

Verdict: the layout and interaction flow is right. The dual-source Sidebar, the stub Project List panel beneath it, the bottom terminal, and the `<C-j>`-leader keybinding scheme all held up once they were real instead of hypothetical — no structural rework needed. The prototype did surface several gaps ticket 05's original question missed, all fixed and re-verified live across three iterations:

1. **Project List panel had no discoverable close key.** `q` worked all along, but single-key buffer-local mappings don't show up in which-key (which only surfaces `<leader>`-prefixed combos), so it felt broken. Fixed with an in-panel footer hint (`[<cr>] switch  [x] remove  [q] close`) rather than changing the key itself.
2. **No open-files tab bar.** Added `akinsho/bufferline.nvim`. Clarified for the record: what it shows are Neovim *buffers* (open files), not Vim "tabs" (a different, rarely-used concept) — general editor vocabulary, not specific enough to this project to need a GLOSSARY entry.
3. **No way to navigate or close buffers, or a familiar save shortcut.** Added a `<leader>b` group (`bn`/`bp`/`bd`), `<S-l>`/`<S-h>` for quick cycling, and `<C-s>` to save. Recorded as an addendum to ticket 05, since this is squarely keybinding-scheme material ticket 05's original question simply didn't cover.
4. **Quitting required closing every window individually** (`:q!` per Sidebar/panel/terminal). Added `<leader>qq` → `:qa!`; verified headless that it exits cleanly even with a terminal job still running. Also recorded on ticket 05.
5. **Live per-line diff markers (added/changed/removed), like VSCode's gutter.** This turned out to already be a settled decision nobody had surfaced to the prototype yet — ADR-0006 locks in `gitsigns.nvim` for exactly this. Wired it in and verified headless (in a scratch git repo with a staged edit) that it correctly reports `added`/`changed`/`removed` counts. No new decision needed, just confirmation the existing one delivers what was asked for.

All fixes were verified headless (via scripted `feedkeys` runs against the actual prototype config) before being handed back for another live pass, across three rounds of user feedback.

Prototype asset: `prototype/layout-skeleton` branch (not merged, no remote configured) — see `.scratch/nvim-ide/prototype/layout-skeleton/init.lua`. Self-contained scratch Neovim config, isolated plugin data under its own `.data/`, launch with `nvim -u .scratch/nvim-ide/prototype/layout-skeleton/init.lua`.
