-- Chrome Navigation Mode (ticket 12): <leader>cn toggles between vim-style
-- window nav and conventional mode, without touching text-editing modality.
local h = dofile(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h") .. "/helpers.lua")

return {
  ["<leader>cn disables, then re-enables, vim-style window nav"] = function()
    h.with_scratch_tab(function()
      vim.cmd("vsplit")
      local right_win = vim.api.nvim_get_current_win()
      vim.cmd("wincmd h")
      local left_win = vim.api.nvim_get_current_win()

      h.feed("<leader>cn") -- vim -> conventional
      h.feed("<leader>l")
      h.eq(vim.api.nvim_get_current_win(), left_win, "<leader>l no longer switches windows once toggled off")

      h.feed("<leader>cn") -- conventional -> vim
      h.feed("<leader>l")
      h.eq(vim.api.nvim_get_current_win(), right_win, "<leader>l switches windows again once toggled back on")
    end)
  end,

  ["toggling Chrome Navigation Mode never touches text-editing modality"] = function()
    h.with_scratch_tab(function()
      vim.cmd("enew")
      h.feed("<leader>cn")
      h.eq(vim.api.nvim_get_mode().mode, "n", "still in Normal mode after toggling")

      local entered_insert = false
      vim.api.nvim_create_autocmd("InsertEnter", {
        once = true,
        callback = function()
          entered_insert = true
        end,
      })
      h.feed("i<Esc>")
      h.truthy(entered_insert, "i still enters Insert mode")

      h.feed("<leader>cn") -- restore default mode for later specs
    end)
  end,
}
