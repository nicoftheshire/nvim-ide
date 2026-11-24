-- Shared helpers for the headless feedkeys-driven test suite (ticket 12).
-- Tests run inside a real nvim-ide instance (the actual init.lua), driving
-- it with scripted keystrokes and asserting on resulting editor state —
-- never mocking the plugins themselves (spec's Testing Decisions).

local M = {}

-- Feed a key sequence synchronously, as if the user typed it, resolving
-- special keys like <leader>/<C-s> first.
function M.feed(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "x", false)
end

function M.eq(actual, expected, msg)
  if actual ~= expected then
    error(string.format("%s: expected %s, got %s", msg or "assertion failed", vim.inspect(expected), vim.inspect(actual)), 2)
  end
end

function M.truthy(value, msg)
  if not value then
    error(msg or "expected a truthy value", 2)
  end
end

-- Open a scratch tab with a fresh 2x2-ish window layout for Chrome
-- Navigation Mode tests, isolated from whatever the rest of the suite left
-- open, and return a cleanup function.
function M.with_scratch_tab(fn)
  vim.cmd("tabnew")
  local ok, err = pcall(fn)
  vim.cmd("tabclose!")
  if not ok then
    error(err, 0)
  end
end

-- :bnext/:bprevious walk the global (cross-tab) buffer list, so buffer-nav
-- tests need their own buffers to be the only listed ones, or leftover
-- buffers from elsewhere in the suite (or Neovim's own initial [No Name]
-- buffer) would make wraparound assertions non-deterministic. Temporarily
-- unlist everything already open, run fn, then restore.
function M.with_isolated_buffer_list(fn)
  local listed = vim.tbl_filter(function(buf)
    return vim.bo[buf].buflisted
  end, vim.api.nvim_list_bufs())
  for _, buf in ipairs(listed) do
    vim.bo[buf].buflisted = false
  end

  local ok, err = pcall(fn)

  for _, buf in ipairs(listed) do
    if vim.api.nvim_buf_is_valid(buf) then
      vim.bo[buf].buflisted = true
    end
  end
  if not ok then
    error(err, 0)
  end
end

-- Open three real file buffers (via tempfiles — assert on resulting buffer
-- state, not a plugin's internals), isolated from whatever else is open.
-- Runs fn(bufs) and tears the buffers and their tempfiles down afterwards.
function M.with_three_file_buffers(fn)
  M.with_isolated_buffer_list(function()
    local bufs = {}
    local paths = {}
    for i = 1, 3 do
      local path = vim.fn.tempname()
      vim.fn.writefile({ "buffer " .. i }, path)
      vim.cmd("edit " .. vim.fn.fnameescape(path))
      table.insert(bufs, vim.api.nvim_get_current_buf())
      table.insert(paths, path)
    end

    local ok, err = pcall(fn, bufs)

    for _, buf in ipairs(bufs) do
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
    for _, path in ipairs(paths) do
      os.remove(path)
    end

    if not ok then
      error(err, 0)
    end
  end)
end

return M
