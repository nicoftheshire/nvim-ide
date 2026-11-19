Type: research
Status: resolved

## Question

The spec needs to name exact Mason package names and `lspconfig`/`nvim-lspconfig` server names for the baseline language set decided during charting: Lua, TypeScript/JavaScript, Python, Java, Terraform.

Verify against current mason.nvim / mason-lspconfig.nvim / nvim-lspconfig documentation:
- For each of the five languages, what's the current recommended Mason package name and corresponding `lspconfig` server name (e.g. `lua_ls`, `ts_ls`/`tsserver`, `pyright` or `basedpyright`, `jdtls`, `terraformls`)?
- `jdtls` (Java) is known for needing more setup than a typical LSP — does it require a per-project workspace directory, a separate `nvim-jdtls` plugin wrapper (vs bare `lspconfig` setup), or other special handling beyond what Mason installs? Document whatever extra config this needs so the spec doesn't understate Java support's complexity.
- Any of the five with unusually heavy install size/startup cost worth flagging against the Startup Budget (ADR-0007) — note that per-language LSP attach time is already excluded from the budget, so this is informational, not a blocker.

Report the exact package/server names and any extra per-language setup notes (especially for jdtls) so the spec's LSP section can be written directly from it.

## Answer

Verified against current mason-registry/mason-lspconfig/nvim-lspconfig sources: Lua uses Mason package `lua-language-server` -> server `lua_ls`; TypeScript/JavaScript uses `typescript-language-server` -> server `ts_ls` (with `vtsls` as the documented fallback given a live TypeScript 7 compatibility issue); Python uses `pyright` -> server `pyright` (or `basedpyright` as an alternative); Java uses `jdtls` -> server `jdtls`; Terraform uses `terraform-ls` -> server `terraformls` (note the hyphen is dropped in the server name). jdtls needs materially more setup than the others: bare `lspconfig`/`vim.lsp.enable('jdtls')` only gets core LSP features, while the `mfussenegger/nvim-jdtls` plugin is "highly recommended" for refactors, debugging, and the JUnit test runner (the two approaches are mutually exclusive); it also needs a persistent per-project workspace directory (auto-handled by nvim-lspconfig's bare config, but must be wired manually if using the plugin) plus a Java 21 runtime and Python 3.9+ for its launcher. Full debug/test parity requires two extra Mason packages (`java-debug-adapter`, `java-test`) and manual DAP wiring, so the spec should scope "baseline" Java to the bare-lspconfig tier and defer debug/test tooling. Per ADR-0007, jdtls is confirmed the clear startup-cost outlier (JVM boot + first-open reindex) while the other four servers are fast native binaries or lightweight Node-based processes — informational only, not a budget blocker.

Also worth feeding into the spec: nvim-lspconfig's legacy `require('lspconfig').X.setup{}` API is deprecated in favor of `vim.lsp.config('X', {...})` + `vim.lsp.enable('X')` (Neovim 0.11+); Mason's GitHub org moved from `williamboman/*` to `mason-org/*` (moved, not archived).

Full findings (citations): `.scratch/nvim-ide/research/lsp-baseline-languages.md` on the (unmerged, local-only) `research/lsp-baseline-languages` branch.
