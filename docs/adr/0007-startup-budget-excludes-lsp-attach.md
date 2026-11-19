# Startup Budget covers Neovim's own cold start, not per-language LSP attach

"Lightweight" is scoped to a concrete, checkable number: Neovim's own cold start, before any LSP client attaches, must stay under 100ms per `nvim --startuptime`. Per-language LSP attach time is explicitly excluded — jdtls (Java) in particular is JVM-based and noticeably slower to initialize than the editor itself, and counting it against the same budget would force dropping Java support to hit the number, which isn't the constraint we actually care about.
