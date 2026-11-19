# Use fzf-lua instead of telescope.nvim for all pickers

telescope.nvim is the ecosystem default for fuzzy finding, but its common performance extension, `telescope-fzf-native`, is a native-compiled binary that must be rebuilt separately on each OS — a direct conflict with the transportable, copy-to-a-different-machine requirement. fzf-lua provides equivalent picker functionality (project switcher, file search, LSP references) with no native-compile step, at the cost of a smaller plugin ecosystem than telescope's.
