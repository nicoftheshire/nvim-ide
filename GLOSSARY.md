# nvim-ide

A personal terminal-based IDE built as a Neovim configuration: a custom shell (sidebar, terminal, project switching) layered over Neovim's editing core.

## Language

**Project**:
A directory the IDE treats as a unit of work, tracked in the Known Projects List and given its own persisted Session.
_Avoid_: workspace, directory, repo

**Known Projects List**:
The persisted list of Projects available through the project switcher, independent of which one is currently open. Entries are added automatically when a new directory is opened and removed explicitly by the user.
_Avoid_: project history, recents

**Session**:
The persisted per-Project state restored when switching back to it: open buffers, tabs, and window layout. Does not include terminal scrollback, which is never persisted.
_Avoid_: workspace state, project state

**Sidebar**:
The togglable panel in the upper part of the left column that shows exactly one of two views at a time: the Tree View or the Changes View. Does not include the Project List panel, which is a separate, always-visible zone stacked beneath it.
_Avoid_: file browser, git panel (neither names the fact it's one slot, not two)

**Project List panel**:
The persistent zone beneath the Sidebar listing every entry in the Known Projects List, for switching to one directly with a keypress — not a picker you summon, always visible regardless of which Sidebar view is active.
_Avoid_: project switcher, project picker (both imply something invoked on demand, not an always-visible list)

**Tree View**:
The Sidebar view showing the Project's file tree.
_Avoid_: file browser, explorer

**Changes View**:
The Sidebar view listing changed files (staged, unstaged, and untracked, each with a distinguishing status icon); selecting one opens it in the diff viewer. Not filtered to unstaged-only — neo-tree's `git_status` source shows all of them together, so "which files have unstaged changes" is answered by the icon, not by the list's membership.
_Avoid_: git panel, git status, unstaged-changes list

**Chrome Navigation Mode**:
The toggle between vim-style and conventional (arrow-key/mouse) keybindings for UI chrome — Sidebar, terminal, panes, window management. Never affects text editing itself, which stays modal regardless, since that's inherent to Neovim.
_Avoid_: vim mode (ambiguous with text-editing modality)

**Startup Budget**:
The constraint that Neovim's own cold start, before any LSP client attaches, stays under 100ms as measured by `nvim --startuptime`. Excludes per-language LSP attach time.
_Avoid_: lightweight (too vague to check against)
