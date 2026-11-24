# nvim-ide

A personal terminal-based IDE built as a Neovim configuration. See `.scratch/nvim-ide/spec.md` for the full spec, `docs/adr/` for architecture decisions, and `GLOSSARY.md` for vocabulary.

## First launch on a new machine

This repo's root is the config root directly — there is no separate installer.

1. Clone or copy this repo to `~/.config/nvim-ide`:
   ```sh
   git clone <this-repo> ~/.config/nvim-ide
   # or: ln -s /path/to/this/checkout ~/.config/nvim-ide
   ```
2. Export `NVIM_APPNAME=nvim-ide` in the shell profile (on Linux, add it to both
   `~/.bashrc` and `~/.bash_profile` — SSH login shells read the latter, other
   shells read the former).
3. Run `nvim` once.

That's it — no `:Lazy sync`, `:Lazy install`, or `:Lazy restore`. lazy.nvim's
`install_missing()` (on by default) reads the committed `lazy-lock.json` and
checks out every plugin at its exact locked commit automatically. Treesitter
parsers and Mason-managed LSP binaries are native/OS-arch-specific and
self-install separately on first launch — they are never synced between
machines.

Treesitter's parser-compile step needs a C compiler (tried in order: `$CC`,
`cc`, `gcc`, `clang`, `cl`, `zig`). macOS has one by default (Xcode CLT); on a
bare Linux box, install a standalone `zig` binary as the fallback instead of a
distro compiler toolchain.

Prerequisites to confirm on each machine before relying on nvim-ide there:
Neovim, `lazygit`, `ripgrep`, and an active Nerd Font (glyph rendering is a
client-side concern on whatever terminal is used, including when SSH'ing into
a remote box).

## Startup Budget

Neovim's own cold start, before any LSP client attaches, must stay under
100ms per `nvim --startuptime` (ADR-0007). Per-language LSP attach time
(notably jdtls's JVM boot) is excluded.
