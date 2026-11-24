# 12: Keybinding scheme, Chrome Navigation Mode, and buffer bar

**What to build:** The `<leader>`-prefixed keybinding foundation (leader key, Chrome Navigation Mode, buffer navigation, save, quit-all) and the open-files tab bar — the parts of the scheme that don't depend on the Sidebar, Project List panel, terminal, or git stack existing yet.

**Blocked by:** 10

**Status:** resolved

- [x] `<leader>` is bound to `<C-j>` (ADR-0008).
- [x] `<leader>cn` toggles Chrome Navigation Mode; in its vim-style state, window navigation is `<leader>` then `h`/`j`/`k`/`l` (not bare `<C-h/j/k/l>`), mirroring the tmux prefix+hjkl gesture. Text-editing modality is unaffected either way.
- [x] `<leader>b` buffer group: `bn`/`bp` next/previous buffer, `bd` close current buffer.
- [x] `<S-l>`/`<S-h>` cycle buffers without the leader.
- [x] `<C-s>` saves in both normal and insert mode, alongside plain `:w`.
- [x] `<leader>qq` executes `:qa!` and exits cleanly, including with a terminal job running (verify once the terminal exists in ticket 15 — write the mapping now, headless-test the clean-exit case there or with a stub terminal job).
- [x] bufferline.nvim renders a tab bar of open buffers (not Vim tabs).
- [x] which-key.nvim surfaces every `<leader>`-prefixed combo added here as it's typed.
- [x] All of the above are covered by headless-Neovim `feedkeys`-driven tests per the spec's Testing Decisions (real config, real keystrokes, assert on resulting buffer/window state).

## Comments

Implemented in `init.lua`, after the `lazy.setup()` call: `<leader>` bound to `<C-j>` (ADR-0008); a `chrome_nav` toggle (`<leader>cn`) that adds/removes the vim-style `<leader>h/j/k/l` window-nav mappings; the `<leader>b` buffer group (`bn`/`bp`/`bd`) plus `<S-l>`/`<S-h>`; `<C-s>` in normal and insert mode; `<leader>qq` → `:qa!`; `bufferline.nvim` (eagerly loaded, no lazy trigger) for the open-files tab bar; and a `<leader>b` group label registered via which-key's own `opts.spec`.

Test suite added under `tests/` (`tests/run.sh` → `NVIM_APPNAME=nvim-ide nvim --headless -u init.lua -c "lua dofile('tests/run.lua')"`, which dofiles every `tests/specs/*_spec.lua`): 15 feedkeys-driven cases across leader-key, Chrome Navigation Mode (nav + toggle), buffer nav, save, quit-all (spawns a real child nvim-ide process with a stub `terminal sleep 60` job to verify `<leader>qq` exits cleanly rather than hanging, ahead of the real terminal in ticket 15), bufferline, and which-key discoverability. Notable gotcha: `VeryLazy`-gated plugins (which-key) never fire under `--headless`, since it's gated on `UIEnter`; tests force-load via a direct `require(...)` instead. Startup Budget re-confirmed at ~15-40ms (ADR-0007).

Reviewed via the `code-review` skill (parallel Standards + Spec sub-agents against ticket 12 and `spec.md`). Fixed: the which-key group test asserted on the plugin's own `add()` API not erroring rather than resulting state — replaced with an assertion against which-key's actual resolved config (`require("which-key.config").options.spec`), proving `init.lua`'s wiring really reached it; the leader-key test only checked `vim.g.mapleader` — added a feedkeys case driving the literal `<C-j>` chord across a window split. Also collapsed the Chrome Navigation Mode keymap setup from four repeated lines into a small table loop, and extracted a shared `with_three_file_buffers` test helper (was duplicated between the buffer-nav and bufferline specs). Chrome Navigation Mode's "conventional" state deliberately binds nothing in place of the vim-style `<leader>h/j/k/l` maps (falling back to Neovim's already-enabled `mouse=a`) — the ticket's checklist only requires the vim-style state be wired and tested here; a dedicated conventional-mode binding isn't asked for by this ticket and would be speculative ahead of the Sidebar/terminal/panes it would actually need to target (tickets 13-15).

Process note: a concurrent session working in this same (non-worktree) checkout committed ticket 11's LSP work (`012b656`) while this ticket was in progress, and that commit's snapshot of `init.lua` swept up all of this ticket's in-progress keybinding code too. This ticket's commit therefore layers on top of that shared history; the keybinding-scheme code itself first appears in `012b656` (bundled with unrelated ticket-11 changes), and this commit adds the remaining fixes plus the `tests/` directory.
