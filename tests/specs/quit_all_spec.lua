-- <leader>qq executes :qa! and exits cleanly, even with a terminal job
-- running (ticket 12). Spawns a real child nvim-ide process rather than
-- asserting in-process, since :qa! ends the process itself.
local h = dofile(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h") .. "/helpers.lua")

return {
  ["<leader>qq exits cleanly with a running terminal job"] = function()
    local repo_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h")
    local fixture = repo_root .. "/tests/fixtures/quit_all_with_terminal_job.lua"

    local exited = false
    local exit_code = nil
    local job = vim.fn.jobstart({
      "nvim",
      "--headless",
      "-u",
      "init.lua",
      "-c",
      "luafile " .. fixture,
    }, {
      cwd = repo_root,
      env = { NVIM_APPNAME = "nvim-ide" },
      on_exit = function(_, code)
        exited = true
        exit_code = code
      end,
    })
    h.truthy(job > 0, "spawned the child nvim-ide process")

    local completed = vim.wait(5000, function()
      return exited
    end, 50)

    if not completed then
      vim.fn.jobstop(job)
    end
    h.truthy(completed, "<leader>qq exited the process within 5s instead of hanging")
    h.eq(exit_code, 0, "process exited cleanly (status 0)")
  end,
}
