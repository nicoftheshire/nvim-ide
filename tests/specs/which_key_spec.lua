-- which-key.nvim surfaces every <leader>-prefixed combo added by the
-- keybinding scheme (ticket 12) as it's typed. which-key renders any keymap
-- automatically once it's triggered; a `desc` is what makes the popup read
-- as a label instead of the raw right-hand side, and a `group` label is
-- what names a multi-key prefix like <leader>b instead of showing "+prefix".
--
-- VeryLazy (which which-key loads on) never fires under --headless (it's
-- gated on UIEnter), so force-load it directly, as a real which-key-aware
-- plugin would on first invocation too.
local h = dofile(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h") .. "/helpers.lua")

local function desc_of(mode, lhs)
  local raw = vim.api.nvim_replace_termcodes(lhs, true, false, true)
  for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
    if map.lhsraw == raw then
      return map.desc
    end
  end
  return nil
end

return {
  ["every <leader>-prefixed mapping from this ticket carries a desc"] = function()
    local leader_mappings = {
      "<leader>cn",
      "<leader>bn",
      "<leader>bp",
      "<leader>bd",
      "<leader>qq",
      "<leader>h",
      "<leader>j",
      "<leader>k",
      "<leader>l",
    }
    for _, lhs in ipairs(leader_mappings) do
      h.truthy(desc_of("n", lhs), lhs .. " has a desc for which-key to render")
    end
  end,

  ["the <leader>b group from init.lua reaches which-key's own config"] = function()
    require("lazy").load({ plugins = { "which-key.nvim" } })
    local spec = require("which-key.config").options.spec

    local group = nil
    for _, entry in ipairs(spec) do
      if entry[1] == "<leader>b" then
        group = entry.group
      end
    end
    h.eq(group, "buffer", "which-key's resolved config carries init.lua's <leader>b group label")
  end,
}
