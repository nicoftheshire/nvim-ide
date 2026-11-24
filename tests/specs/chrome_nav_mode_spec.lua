-- Chrome Navigation Mode (ticket 12): in its vim-style state, window
-- navigation is <leader> then h/j/k/l, not bare <C-h/j/k/l>.
local h = dofile(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h") .. "/helpers.lua")

return {
  ["<leader>l/<leader>h move focus across a vertical split"] = function()
    h.with_scratch_tab(function()
      vim.cmd("vsplit")
      local right_win = vim.api.nvim_get_current_win()
      vim.cmd("wincmd h")
      local left_win = vim.api.nvim_get_current_win()
      h.truthy(left_win ~= right_win, "split produced two distinct windows")

      h.feed("<leader>l")
      h.eq(vim.api.nvim_get_current_win(), right_win, "<leader>l moved focus right")

      h.feed("<leader>h")
      h.eq(vim.api.nvim_get_current_win(), left_win, "<leader>h moved focus left")
    end)
  end,

  ["<leader>j/<leader>k move focus across a horizontal split"] = function()
    h.with_scratch_tab(function()
      -- splitbelow=true (init.lua) puts the new window, and focus, below.
      vim.cmd("split")
      local bottom_win = vim.api.nvim_get_current_win()
      vim.cmd("wincmd k")
      local top_win = vim.api.nvim_get_current_win()
      h.truthy(top_win ~= bottom_win, "split produced two distinct windows")

      h.feed("<leader>j")
      h.eq(vim.api.nvim_get_current_win(), bottom_win, "<leader>j moved focus down")

      h.feed("<leader>k")
      h.eq(vim.api.nvim_get_current_win(), top_win, "<leader>k moved focus up")
    end)
  end,
}
