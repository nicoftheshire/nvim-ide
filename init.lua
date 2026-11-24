-- nvim-ide: a personal terminal-based IDE built as a Neovim config.
--
-- Kickstart.nvim-style base (ADR-0001): a small, readable init.lua wiring up
-- a plugin manager, treesitter, and Mason plumbing, with no opinionated UI
-- baked in. The custom shell (Sidebar, Project List panel, terminal,
-- git/diff/graph stack, keybinding scheme) is layered on in later tickets.
--
-- Isolated under NVIM_APPNAME=nvim-ide (ADR-0002): this repo is the config
-- root directly. Place/symlink it at ~/.config/nvim-ide, export
-- NVIM_APPNAME=nvim-ide in the shell profile, then run `nvim` once — no
-- separate installer, no :Lazy sync/install/restore required or run.

vim.g.have_nerd_font = true

-- ADR-0008: leader is <C-j>, mirroring the user's tmux prefix. Set before
-- any keymap uses <leader> (the keybinding scheme itself lives at the
-- bottom of this file, after plugins are declared).
vim.g.mapleader = vim.api.nvim_replace_termcodes("<C-j>", true, false, true)
vim.g.maplocalleader = vim.g.mapleader

vim.opt.number = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 10

-- Deferred so loading a clipboard provider (xclip/xsel/wl-copy/pbcopy, etc.)
-- doesn't push a slow provider probe into the Startup Budget (ADR-0007).
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- Bootstrap lazy.nvim -------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Plugins ---------------------------------------------------------------
-- The Sidebar, Project List panel, terminal, and git/diff/graph stack are
-- deliberately not wired up here yet (later tickets); the keybinding
-- scheme (ticket 12) lives below, after plugin setup.
require("lazy").setup({
  { -- Treesitter: parsing for highlighting, indentation, and text objects.
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },
      auto_install = true,
      highlight = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  { -- Mason: installs and manages external editor tooling (LSP servers, etc.)
    "mason-org/mason.nvim",
    opts = {},
  },
  { -- mason-lspconfig: bridges Mason-installed servers into vim.lsp.config,
    -- enabling via vim.lsp.enable (Neovim 0.11+), never the deprecated
    -- require('lspconfig').X.setup{} form.
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      -- lua_ls needs to know about `vim` globals when editing this config;
      -- the other four baseline servers use their nvim-lspconfig defaults.
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
              checkThirdParty = false,
              library = { vim.env.VIMRUNTIME },
            },
          },
        },
      })

      require("mason-lspconfig").setup({
        -- Baseline five (ADR: see spec's LSP baseline section). jdtls is
        -- bare lspconfig only — no nvim-jdtls, debug adapter, or test
        -- runner (explicitly deferred). Its JVM startup is excluded from
        -- the Startup Budget by ADR-0007.
        ensure_installed = { "lua_ls", "ts_ls", "pyright", "jdtls", "terraformls" },
        automatic_enable = true,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("nvim-ide-lsp-attach", { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if not client then
            return
          end

          if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
          end

          if client:supports_method("textDocument/references") then
            vim.keymap.set("n", "grr", function()
              require("fzf-lua").lsp_references()
            end, { buffer = event.buf, desc = "LSP: [G]oto [R]eferences (fzf-lua)" })
          end
        end,
      })
    end,
  },
  { -- fzf-lua: the picker for file search and LSP references (ADR-0004) —
    -- no native-compiled dependency, unlike telescope-fzf-native.
    "ibhagwan/fzf-lua",
    opts = {},
    keys = {
      { "<C-p>", function() require("fzf-lua").files() end, desc = "Find files (fzf-lua)" },
    },
  },
  { -- which-key: surfaces keybindings as they're typed. Individual leaf
    -- mappings are picked up automatically from their own `desc`; only
    -- multi-key prefixes need an explicit group label here (ticket 12).
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>b", group = "buffer" },
      },
    },
  },
  { -- bufferline: the open-files tab bar (ticket 12) — Neovim buffers, not
    -- Vim tabs, per ticket 06's finding.
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },
}, {
  install = { colorscheme = { "default" } },
})

-- Keybinding scheme (ticket 12) ---------------------------------------------

-- Chrome Navigation Mode: toggle between vim-style (<leader> then h/j/k/l
-- for window nav, mirroring the tmux prefix+hjkl gesture, ADR-0008) and
-- conventional UI-chrome navigation. Never affects text-editing modality.
local chrome_nav = { mode = "vim" }

local window_nav_keys = {
  h = { rhs = "<C-w>h", desc = "Window left" },
  j = { rhs = "<C-w>j", desc = "Window down" },
  k = { rhs = "<C-w>k", desc = "Window up" },
  l = { rhs = "<C-w>l", desc = "Window right" },
}

local function apply_chrome_nav_mode()
  for key, map in pairs(window_nav_keys) do
    if chrome_nav.mode == "vim" then
      vim.keymap.set("n", "<leader>" .. key, map.rhs, { desc = map.desc })
    else
      pcall(vim.keymap.del, "n", "<leader>" .. key)
    end
  end
end

apply_chrome_nav_mode()

vim.keymap.set("n", "<leader>cn", function()
  chrome_nav.mode = chrome_nav.mode == "vim" and "conventional" or "vim"
  apply_chrome_nav_mode()
  vim.notify("Chrome Navigation Mode: " .. chrome_nav.mode)
end, { desc = "Toggle Chrome Navigation Mode" })

-- <leader>b buffer group, plus <S-l>/<S-h> quick-cycling without the leader.
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Close buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer (quick)" })
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer (quick)" })

-- Save: plain :w already works; <C-s> added as a familiar IDE-style
-- shortcut alongside it, not a replacement.
vim.keymap.set({ "n", "i" }, "<C-s>", "<cmd>w<cr>", { desc = "Save" })

-- Quit everything at once, including any running terminal jobs.
vim.keymap.set("n", "<leader>qq", "<cmd>qa!<cr>", { desc = "Quit everything" })
