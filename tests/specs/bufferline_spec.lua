-- bufferline.nvim renders a tab bar of open buffers, not Vim tabs (ticket
-- 12, per ticket 06's finding). Asserted through its own public
-- get_elements() API (the same one a custom statusline would use), not by
-- reading its config table.
local h = dofile(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h") .. "/helpers.lua")

return {
  ["bufferline lists every open file buffer, and drops it once closed"] = function()
    h.with_three_file_buffers(function(bufs)
      vim.cmd("redraw!")

      local function listed_ids()
        local ids = {}
        for _, el in ipairs(require("bufferline").get_elements().elements) do
          ids[el.id] = true
        end
        return ids
      end

      local ids = listed_ids()
      for _, buf in ipairs(bufs) do
        h.truthy(ids[buf], "bufferline lists buffer " .. buf)
      end

      vim.api.nvim_buf_delete(bufs[2], { force = true })
      vim.cmd("redraw!")
      ids = listed_ids()
      h.truthy(not ids[bufs[2]], "bufferline drops a buffer once it's closed")
    end)
  end,
}
