-- PROTOTYPE (wayfinder ticket 06): nvim-ide layout/interaction skeleton.
-- THROWAWAY CODE — not part of the real build. Validates layout/interaction
-- feel for the already-ADR-decided shell: Sidebar (neo-tree dual-source) +
-- stub Project List panel (ADR-0009) + bottom terminal + Chrome Navigation
-- Mode toggle, wired with the <C-j> leader scheme from ticket 05 (ADR-0008).
--
-- Fully isolated from any real Neovim config: all plugin data lives under
-- ./.data next to this file. Launch with:
--
--   nvim -u .scratch/nvim-ide/prototype/layout-skeleton/init.lua
--
-- First launch will clone plugins (needs network); subsequent launches are fast.

local prototype_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")
local data_root = prototype_root .. "/.data"
vim.env.XDG_DATA_HOME = data_root .. "/data"
vim.env.XDG_STATE_HOME = data_root .. "/state"
vim.env.XDG_CACHE_HOME = data_root .. "/cache"

-- ADR-0008: leader is <C-j>, mirroring the user's tmux prefix.
vim.g.mapleader = vim.api.nvim_replace_termcodes("<C-j>", true, true, true)
vim.g.maplocalleader = vim.g.mapleader

vim.opt.number = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"

-- bootstrap lazy.nvim, scoped to the isolated data dir
local lazypath = data_root .. "/data/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "nvim-lua/plenary.nvim" },
  { "nvim-tree/nvim-web-devicons" },
  { "MunifTanjim/nui.nvim" },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "main",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
    opts = {
      source_selector = {
        winbar = true,
        sources = {
          { source = "filesystem" },
          { source = "git_status" },
        },
      },
      git_status = {
        window = {
          mappings = { ["<cr>"] = "open_in_diffview_stub" },
        },
        commands = {
          -- real build wires this to diffview.nvim (ticket 01); stubbed here
          -- since diffview isn't part of what this prototype is checking.
          open_in_diffview_stub = function(state)
            local node = state.tree:get_node()
            vim.notify("PROTOTYPE: would open diffview for " .. (node.path or node.id))
          end,
        },
      },
    },
  },
  {
    "akinsho/toggleterm.nvim",
    opts = { direction = "horizontal", size = 15 },
  },
  {
    "folke/which-key.nvim",
    opts = {},
  },
}, {
  root = data_root .. "/data/lazy",
})

-- Project List panel stub (ADR-0009) ----------------------------------------
-- No plugin exists for this; it's new, custom UI. Good enough here to judge
-- the *feel* of an always-visible panel stacked beneath the Sidebar.
local ProjectPanel = {}
ProjectPanel.projects = { "nvim-ide", "api-service", "marketing-site", "dotfiles" }
ProjectPanel.buf = nil
ProjectPanel.win = nil

function ProjectPanel.render()
  if not (ProjectPanel.buf and vim.api.nvim_buf_is_valid(ProjectPanel.buf)) then
    return
  end
  vim.api.nvim_set_option_value("modifiable", true, { buf = ProjectPanel.buf })
  local lines = { " PROJECTS", "" }
  for _, p in ipairs(ProjectPanel.projects) do
    table.insert(lines, "   " .. p)
  end
  vim.api.nvim_buf_set_lines(ProjectPanel.buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = ProjectPanel.buf })
end

local function selected_project()
  local row = vim.api.nvim_win_get_cursor(ProjectPanel.win)[1]
  local idx = row - 2
  return ProjectPanel.projects[idx], idx
end

function ProjectPanel.open()
  local neotree_win
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_get_option_value("filetype", { buf = buf }) == "neo-tree" then
      neotree_win = win
      break
    end
  end
  if not neotree_win then
    vim.notify("Open the Sidebar first (<leader>ss)", vim.log.levels.WARN)
    return
  end

  if ProjectPanel.win and vim.api.nvim_win_is_valid(ProjectPanel.win) then
    vim.api.nvim_set_current_win(ProjectPanel.win)
    return
  end

  vim.api.nvim_set_current_win(neotree_win)
  vim.cmd("belowright split")
  ProjectPanel.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_height(ProjectPanel.win, 8)

  ProjectPanel.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(ProjectPanel.win, ProjectPanel.buf)
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = ProjectPanel.buf })
  vim.api.nvim_set_option_value("filetype", "project-list-panel", { buf = ProjectPanel.buf })
  vim.api.nvim_set_option_value("number", false, { win = ProjectPanel.win })
  vim.api.nvim_set_option_value("cursorline", true, { win = ProjectPanel.win })

  ProjectPanel.render()
  vim.api.nvim_win_set_cursor(ProjectPanel.win, { 3, 0 })

  local opts = { buffer = ProjectPanel.buf, nowait = true, silent = true }
  vim.keymap.set("n", "<cr>", function()
    local name = selected_project()
    if name then
      vim.notify("PROTOTYPE: switching to project '" .. name .. "'")
    end
  end, opts)
  vim.keymap.set("n", "x", function()
    local name, idx = selected_project()
    if name then
      table.remove(ProjectPanel.projects, idx)
      ProjectPanel.render()
      vim.notify("PROTOTYPE: removed project '" .. name .. "'")
    end
  end, opts)
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(ProjectPanel.win, true)
  end, opts)
end

-- Chrome Navigation Mode stub -------------------------------------------
local chrome_nav_mode = "vim"
local function toggle_chrome_nav_mode()
  chrome_nav_mode = chrome_nav_mode == "vim" and "conventional" or "vim"
  vim.notify("PROTOTYPE: Chrome Navigation Mode -> " .. chrome_nav_mode)
end

-- Keymaps: ticket 05's scheme, leader = <C-j> (ADR-0008) ------------------
local map = vim.keymap.set

map("n", "<leader>h", "<C-w>h", { desc = "Window left" })
map("n", "<leader>j", "<C-w>j", { desc = "Window down" })
map("n", "<leader>k", "<C-w>k", { desc = "Window up" })
map("n", "<leader>l", "<C-w>l", { desc = "Window right" })

-- <leader>s — Sidebar group
map("n", "<leader>ss", "<cmd>Neotree toggle filesystem left<cr>", { desc = "Toggle Sidebar" })
local sidebar_source = "filesystem"
map("n", "<leader>sv", function()
  sidebar_source = sidebar_source == "filesystem" and "git_status" or "filesystem"
  vim.cmd("Neotree focus " .. sidebar_source .. " left")
end, { desc = "Switch Sidebar view" })
map("n", "<leader>sp", ProjectPanel.open, { desc = "Focus Project List panel" })

-- <leader>t — Terminal group
local Terminal = require("toggleterm.terminal").Terminal
local terms = {}
local function get_term(n)
  terms[n] = terms[n] or Terminal:new({ count = n })
  return terms[n]
end
map("n", "<leader>tt", function() get_term(1):toggle() end, { desc = "Toggle terminal" })
for i = 1, 4 do
  map("n", "<leader>t" .. i, function() get_term(i):toggle() end, { desc = "Terminal " .. i })
end
map("n", "<leader>tn", function()
  local n = tonumber(vim.fn.input("Terminal #: "))
  if n then get_term(n):toggle() end
end, { desc = "Open terminal N" })

-- <leader>g — Git group
map("n", "<leader>gg", function() get_term(99):toggle() end, { desc = "Open lazygit (stub terminal)" })
map("n", "<leader>gs", function()
  vim.notify("PROTOTYPE: would open neogit here")
end, { desc = "Open neogit (stub)" })

-- <leader>cn — Chrome Navigation Mode toggle
map("n", "<leader>cn", toggle_chrome_nav_mode, { desc = "Toggle Chrome Navigation Mode" })

vim.notify("nvim-ide layout prototype loaded. <C-j>ss = Sidebar, <C-j>sp = Project List panel, <C-j>tt = terminal.")
