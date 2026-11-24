-- <C-s> saves in both Normal and Insert mode, alongside plain :w (ticket 12).
local h = dofile(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h") .. "/helpers.lua")

local function with_scratch_file(fn)
  h.with_isolated_buffer_list(function()
    local path = vim.fn.tempname()
    vim.fn.writefile({ "original" }, path)
    vim.cmd("edit " .. vim.fn.fnameescape(path))
    local buf = vim.api.nvim_get_current_buf()

    local ok, err = pcall(fn, buf, path)

    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
    os.remove(path)

    if not ok then
      error(err, 0)
    end
  end)
end

return {
  ["<C-s> saves in Normal mode"] = function()
    with_scratch_file(function(buf, path)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "changed in normal mode" })
      h.truthy(vim.bo[buf].modified, "buffer is dirty before saving")

      h.feed("<C-s>")

      h.truthy(not vim.bo[buf].modified, "<C-s> cleared the modified flag")
      h.eq(vim.fn.readfile(path)[1], "changed in normal mode", "<C-s> wrote the new content to disk")
    end)
  end,

  ["<C-s> saves in Insert mode"] = function()
    with_scratch_file(function(buf, path)
      h.feed("ggA changed in insert mode<C-s>")

      h.truthy(not vim.bo[buf].modified, "<C-s> cleared the modified flag from Insert mode")
      h.eq(vim.fn.readfile(path)[1], "original changed in insert mode", "<C-s> wrote the new content to disk")

      h.feed("<Esc>")
    end)
  end,
}
