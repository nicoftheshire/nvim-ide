-- ADR-0008: <leader> is bound to <C-j>.
local h = dofile(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h") .. "/helpers.lua")

return {
  ["<leader> resolves to <C-j>"] = function()
    local expected = vim.api.nvim_replace_termcodes("<C-j>", true, false, true)
    h.eq(vim.g.mapleader, expected, "mapleader")
    h.eq(vim.g.maplocalleader, expected, "maplocalleader")
  end,

  ["the physical <C-j> keystroke triggers a leader-mapped command"] = function()
    h.with_scratch_tab(function()
      vim.cmd("vsplit")
      local right_win = vim.api.nvim_get_current_win()
      vim.cmd("wincmd h")
      local left_win = vim.api.nvim_get_current_win()

      -- Fed as the raw <C-j> chord, not the <leader> placeholder notation,
      -- to prove the actual physical key is wired up, not just vim.g.mapleader.
      h.feed("<C-j>l")
      h.eq(vim.api.nvim_get_current_win(), right_win, "<C-j>l moved focus right")

      h.feed("<C-j>h")
      h.eq(vim.api.nvim_get_current_win(), left_win, "<C-j>h moved focus left")
    end)
  end,
}
