-- Headless test runner (ticket 12). Invoked via tests/run.sh, which launches
-- a real nvim-ide instance (-u init.lua) and dofiles this.
--
-- Each file under tests/specs/ returns a table mapping a description to a
-- test function. Test functions are run in sequence, in-process, against
-- the one real nvim-ide instance this runner is loaded into.

local spec_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h") .. "/specs"

local failures = {}
local total = 0

for name in vim.fs.dir(spec_dir) do
  if name:match("_spec%.lua$") then
    local spec = dofile(spec_dir .. "/" .. name)
    for description, test in pairs(spec) do
      total = total + 1
      local ok, err = pcall(test)
      if ok then
        io.stdout:write(string.format("ok   %s: %s\n", name, description))
      else
        io.stdout:write(string.format("FAIL %s: %s\n  %s\n", name, description, tostring(err)))
        table.insert(failures, name .. ": " .. description)
      end
    end
  end
end

io.stdout:write(string.format("\n%d passed, %d failed, %d total\n", total - #failures, #failures, total))

if #failures > 0 then
  vim.cmd("cquit 1")
else
  vim.cmd("qa!")
end
