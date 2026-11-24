-- Fixture run inside a child nvim-ide process by quit_all_spec.lua: opens a
-- long-running stub terminal job, then feeds <leader>qq, to prove the
-- mapping exits cleanly even with a job still running (ticket 12 asks this
-- be verified now with a stub, ahead of the real terminal in ticket 15).
vim.cmd("terminal sleep 60")

local function feed(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "x", false)
end

vim.defer_fn(function()
  feed("<C-\\><C-n>") -- leave terminal mode before a Normal-mode leader mapping
  feed("<leader>qq")
end, 200)
