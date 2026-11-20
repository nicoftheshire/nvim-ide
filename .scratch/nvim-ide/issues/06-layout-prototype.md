Type: prototype
Status: claimed
Blocked by: 01, 04, 05

## Question

Before locking the spec's layout and interaction section, build a rough, throwaway skeleton of nvim-ide's core shell to react to: the Sidebar (neo-tree dual-source toggle per ticket 01's findings) with a stub Project List panel beneath it (per ADR-0009 — this replaces the originally-planned fzf-lua Project switcher), the bottom toggleterm terminal, and the Chrome Navigation Mode toggle, wired with the keybinding scheme from ticket 05 (leader `<C-j>`, per ADR-0008). Not polished, not the real build — just enough to answer "does this actual layout and interaction flow feel right," and surface anything the grilled decisions missed once it's real instead of hypothetical.
