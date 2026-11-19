# Use possession.nvim instead of auto-session for Session persistence

possession.nvim manages an explicit list of named sessions (save/load/list/delete) rather than auto-session's purely cwd-keyed, implicit model. The Known Projects List already needs explicit add/remove semantics, so a session plugin with the same explicit-list shape integrates more directly than one built around automatic directory-keyed saves.
