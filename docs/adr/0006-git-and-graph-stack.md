# Git/diff/graph stack combines four tools, including one external binary

The Changes View is backed by gitsigns.nvim (inline hunk signs) and neogit (the stage/commit workflow, opened as its own window), diffview.nvim renders diffs, and the repo graph specifically is the external `lazygit` binary embedded in a toggleterm float rather than a pure-Lua graph plugin. No Lua-native plugin matches lazygit's graph view, so we accept one extra external dependency (installed via the system package manager on each machine) instead of a weaker in-editor graph.
