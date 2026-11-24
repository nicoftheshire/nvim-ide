-- <leader>b buffer group (ticket 12): bn/bp next/previous buffer, bd close
-- current buffer; <S-l>/<S-h> cycle buffers without the leader.
--
-- Deliberately does *not* run inside a scratch tab (contrast with
-- chrome_nav_mode_spec): a tab created purely for isolation has no window
-- history of its own, so deleting the last buffer it ever showed closes the
-- tab instead of falling back to another listed buffer — a real Neovim
-- quirk that's irrelevant here, since nvim-ide's own buffer bar
-- (bufferline, not Vim tabs) never puts the user in that situation.
local h = dofile(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h") .. "/helpers.lua")

return {
  ["<leader>bn/<leader>bp cycle next/previous through open buffers"] = function()
    h.with_three_file_buffers(function(bufs)
      -- after opening three in turn, we're on the third (bufs[3])
      h.eq(vim.api.nvim_get_current_buf(), bufs[3], "starts on the last-opened buffer")

      h.feed("<leader>bn")
      h.eq(vim.api.nvim_get_current_buf(), bufs[1], "bn wraps to the first buffer")

      h.feed("<leader>bp")
      h.eq(vim.api.nvim_get_current_buf(), bufs[3], "bp moves back to the last buffer")
    end)
  end,

  ["<S-l>/<S-h> cycle buffers without the leader"] = function()
    h.with_three_file_buffers(function(bufs)
      h.feed("<S-l>")
      h.eq(vim.api.nvim_get_current_buf(), bufs[1], "<S-l> wraps to the first buffer")

      h.feed("<S-h>")
      h.eq(vim.api.nvim_get_current_buf(), bufs[3], "<S-h> moves back to the last buffer")
    end)
  end,

  ["<leader>bd closes the current buffer"] = function()
    h.with_three_file_buffers(function(bufs)
      local closing = bufs[3]
      h.feed("<leader>bd")
      h.truthy(
        not vim.api.nvim_buf_is_valid(closing) or not vim.bo[closing].buflisted,
        "bd removed the buffer from the buffer list"
      )
      h.truthy(vim.api.nvim_get_current_buf() ~= closing, "focus moved off the closed buffer")
    end)
  end,
}
