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
-- LSP servers (ticket 11), the keybinding scheme (ticket 12), and the rest
-- of the custom shell are deliberately not wired up here.
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
  { -- mason-lspconfig: bridges Mason-installed servers into vim.lsp.config.
    -- Plumbing only here — no servers requested yet; that's ticket 11.
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {},
  },
  { -- which-key: surfaces keybindings as they're typed. Base config only —
    -- leader-group content comes in ticket 12.
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },
}, {
  install = { colorscheme = { "default" } },
})
