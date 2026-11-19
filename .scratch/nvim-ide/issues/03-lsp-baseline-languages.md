Type: research
Status: open

## Question

The spec needs to name exact Mason package names and `lspconfig`/`nvim-lspconfig` server names for the baseline language set decided during charting: Lua, TypeScript/JavaScript, Python, Java, Terraform.

Verify against current mason.nvim / mason-lspconfig.nvim / nvim-lspconfig documentation:
- For each of the five languages, what's the current recommended Mason package name and corresponding `lspconfig` server name (e.g. `lua_ls`, `ts_ls`/`tsserver`, `pyright` or `basedpyright`, `jdtls`, `terraformls`)?
- `jdtls` (Java) is known for needing more setup than a typical LSP — does it require a per-project workspace directory, a separate `nvim-jdtls` plugin wrapper (vs bare `lspconfig` setup), or other special handling beyond what Mason installs? Document whatever extra config this needs so the spec doesn't understate Java support's complexity.
- Any of the five with unusually heavy install size/startup cost worth flagging against the Startup Budget (ADR-0007) — note that per-language LSP attach time is already excluded from the budget, so this is informational, not a blocker.

Report the exact package/server names and any extra per-language setup notes (especially for jdtls) so the spec's LSP section can be written directly from it.
